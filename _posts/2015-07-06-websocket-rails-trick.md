---
title: websocket-rails 的坑
layout: post
tag: [rails, websocket, sidekiq]
level: 初级
brief: websocket-rails 这个 gem 提供了异步推送的封装，可在配合 sidekiq 使用的时候，是否是 standalone 模式会产生不同的行为，引发 bugs。
image_url: "/assets/images/rails.jpeg"
---

消耗资源大且慢的系统业务一般会做异步的处理，然后再通过 websocket 推送回给前台。[websocket-rails](https://github.com/websocket-rails/websocket-rails)这个 gem 就提供了这样的封装。

<br />
它的配置很简单，如下:
{% highlight ruby %}

if Rails.env.development?
  WebsocketRails.setup do |config|
    config.standalone = false
    config.synchronize = false
    config.broadcast_subscriber_events = true
  end

elsif Rails.env.staging? || Rails.env.production?
     WebsocketRails.setup do |config|
    config.standalone = true
    config.synchronize = false
    config.broadcast_subscriber_events = true
  end

else 
end
{% endhighlight %}

由于本地使用了 thin 服务，而 staging 和 production 环境都使用了 unicorn 服务，根据 websocket-rails 的官网，非 eventmachine based 的服务器必须配置为 standalone = true。
这样并没有问题，但如果配合异步的处理，如加入 sidekiq，那就出现 bug 了。

重现的方式如下：

假设你有一个 sidekiq 的 worker如下

{% highlight ruby %}
class GetThingDoneWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 1
  
  def perform
    get_thing_done
    WebsocketRails[:some_public_channel].trigger(
        channel_id, { message: "Sorry I am late!"})
  end
end
{% endhighlight %}

在其他的代码中调用这个 worker如下:
{% highlight ruby %}
GetThingDoneWorker.perform_asyn
{% endhighlight %}

在 standalone = false 的情况下，worker 会被调用，运用 get_thing_done 方法，也会去推送更新，但是在接受端总是不能收到推送。

但是在 standalone = true 的情况下就不会出现这个问题。

这就是 bug。到现在为止还不知道出现的原因。

后续：

- 在 github 上面提出 issue，问题还是应该考究下去，增进对 eventmachine 的理解。