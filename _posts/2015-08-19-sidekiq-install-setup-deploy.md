---
title: Sidekiq 的安装，配置和部署
layout: post
tag: [Sidekiq, Capistrano]
level: 初级
brief: 最简最快配置 Sidekiq，不二家。
image_url: "/assets/images/sidekiq-2.png"
---

#{{ page.title }}

####安装
本文是使用的 rails 版本是 '4.1.7'。
添加以下 gem 到 Gemfile，详细如何创建 Sidekiq Job 可以查看 [Getting Started](https://github.com/mperham/sidekiq/wiki/Getting-Started)：

{% highlight ruby linenos%}
gem 'sidekiq', '3.3.0'
gem 'redis', '3.2.0'
{% endhighlight %}

####配置 Redis
创建如下文件，同时按照如下配置 Sidekiq 和 Redis 的链接，详情可 [点击](https://github.com/mperham/sidekiq/wiki/Using-Redis)： 
>config/initializers/sidekiq.rb
{% highlight ruby linenos%}
Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/12' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/12' }
end
{% endhighlight %}
把 **6379** 替换为您使用的 Redis 的接口。 

####配置 Web UI
配置监测的图形界面简单如下，详细信息可以查看 [官网](https://github.com/mperham/sidekiq/wiki/Monitoring)：

- 首先安装 Sinatra
{% highlight ruby linenos%}
gem 'sinatra', :require => nil
{% endhighlight %}

- mount sidekiq 的路由

在 routes.rb 文件中添加如下信息：
{% highlight ruby linenos%}
require 'sidekiq/web'
mount Sidekiq::Web => '/sidekiq'
{% endhighlight %}

- 设置访问权限
 
采用简单的 Basic Auth 就可以完成 Web UI 权限的控制，在 config/initializers/sidekiq.rb 中添加如下代码：
{% highlight ruby linenos%}
Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ["your_username", "your_password"]
end
{% endhighlight %}

####部署
Sidekiq 有了 [Cap Gem](https://github.com/seuros/capistrano-sidekiq/wiki) 的支持，虽然也很简单，可是在实际操作的时候，却不一定那么顺利。如果您碰到了问题，却找不到解决方法，可以尝试以下步骤。

- 安装 Cap recipe

添加以下代码到 Gemfile
{% highlight ruby linenos%}
group :development do
	gem 'capistrano-sidekiq', '0.4.0'
end
{% endhighlight %}

同时千万不要按照官方文档介绍的添加以下这段信息。会导致最新的版本安装，这个版本的 cap hooks 不能顺利被添加。文主也不知为何，或许和使用的 Capistrano 版本有关。
>github: 'seuros/capistrano-sidekiq'

- 本地配置

如下是开发环境中的配置文件，设置了 pid 和 log 的 path。

{% highlight ruby linenos%}
:concurrency: 5
:pidfile: ./tmp/pids/sidekiq.pid
:logfile: ./log/sidekiq.log 
:queues:
    - default
development:
  :verbose: true
  :concurrency: 5
staging:
  :concurrency: 10
production:
  :concurrency: 20
{% endhighlight %}

- 部署配置

按照部署的惯例，pid 和 log 的文件会放在 share/tmp 和 share/log 中。可以在 config/deploy/staging.rb 和 config/deploy/production.rb 配置。

{% highlight ruby linenos%}
# 设置 soft link
set :linked_dirs, %w{tmp log}

# 配置 sidekiq 
set :sidekiq_concurrency, 20
set :sidekiq_pid, -> { File.join(shared_path, 'tmp', 'sidekiq.pid') }
set :sidekiq_log, -> { File.join(shared_path, 'log', 'sidekiq.log') }
{% endhighlight %}

但是 cap 部署的时候不会自动创建 tmp 和 log 文件夹，需要到服务器上手动创建。

{% highlight bash linenos%}
cd path_to_deploy_to_share_folder
mkdir tmp
mkdir log
{% endhighlight %}



