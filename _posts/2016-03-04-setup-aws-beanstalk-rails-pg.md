---
title: AWS 使用小记－ Beanstalk + Rails + Passenger + PostgreSQL
layout: post
tag: [AWS, Beanstalk, Rails]
level: 入门
brief: 技术栈还包括了 WebSocket, Sidekiq 和 Redis，使得启动变得小坑不断。而在填坑的期间，文档和论坛帮了不少忙，可是网上实战的例子很少（几乎没有）。我作为尝试螃蟹的人，吃起来真是费劲。
image_url: "/assets/images/aws.jpg"
---
{{ page.title }}
----

**初步迁徙计划**

这是一个 SAAS 的项目，除了基本的 rails 逻辑和数据库（pg），还要用到 WebSocket，redis 和 Sidekiq。目前所有的业务逻辑，数据库和服务都是单机跑通，一旦有什么 bug 或大访问，只要系统当机那么面相用户的服务也就断了。在产品快速建模实验市场反应的时候，这样做问题不大。但不能不防患未然。所以想到了把此项目迁徙到 AWS 上。既然是用了 AWS 的服务，那么就应该利用它的 elastic 的优势，把项目生产环境配置成为 scalable 的。那么就要解决以下的问题：

- 用什么来跑业务逻辑？
- 用什么来 host 数据库？
- Redis 是部署在单机还是集群？
- WebSocket 如何布置和启动？
- sidekiq 如何布置和启动？

初步阅读了 AWS 文档和看了网上视频后，发现 AWS 有专门针对 Rails 项目的架构服务，一个是 [Beanstalk](https://aws.amazon.com/documentation/elastic-beanstalk/)，一个是 OpsWork。但是后者在中国区不提供服务，所以我打算尝试前者。那么初步的架构设计如下：

- 采用 Beanstalk 的服务，用 EC2 来 host Web Server/App Server
- 采用 RDS postgresql 做数据库服务器
- 采用 ElasticCache Redis 来做缓存服务器
- WebSocket 和 Sidekiq 跑在 EC2 服务器上，通过 Redis 来同步数据

**详细迁徙计划**

经过反复实践和考察，迁徙包括了以下的详细步骤：

- 安装 EB Command Line
- 创建 Instance Profile
- 创建 Beanstalk App
- EB init & EB setup --ssh
- 配置 database.yml，用到 RDS 的服务
- 配置必要的 env variables
- 配置 passenger 对应的 nginx
- 通过 ebextensions 文件夹创建 elastic cache 的 instance
- 配置启动 sidekiq，Websocket 的 任务
- 配置 sidekiq，redis 和 websocket 指向 eb cache 的服务 endpoint
- 部署

**创建 Instance Profile & Beanstalk App**

首先要有一个 AWS 的账号，可以登陆到管理后台，管理后台如下图所示。然后是需要安装一个 eb commandline tool，安装过程就不赘述，[文档在此](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html)。
<div>
  <img style="width:700px" class="graf-image" src="{{ site.url }}/assets/images/aws_console.png">
</div>

在搭建 Beanstalk 服务之前，还需要定义 [Instance Profile](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts-roles.html#concepts-roles-instance)。简单来说它是定义一个角色（role）以及这个角色可以操作资源（S3, EC2, SQS, DynamoDB, CloudWatch）的权限。在 console 页面上面找到定义 profile 的入口。
<div>
  <img style="width:700px" class="graf-image" src="{{ site.url }}/assets/images/aws_instance_profile.png">
</div>

然后选择 "roles" -> "create new roles"。在第一步中定义 role 的名字，然后进入第二部如下图。在这里给 profile 访问 EC2 的权限，选择 EC2 项目。
<div>
  <img style="width:750px" class="graf-image" src="{{ site.url }}/assets/images/iam_step_2.png">
</div>

权限选择 full access。然后一直下一步就完成了 profile 的定义。记住你定义的 profile 的名字，下面创建 beanstalk instance 的时候会用到。

<div>
  <img style="width:750px" class="graf-image" src="{{ site.url }}/assets/images/iam_step_3.png">
</div>

下面就是创建 beanstalk instance。在 console 页面上面找到进入 Elastic Beanstalk 的入口，然后选择 "Create New Application"。然后步骤如下：

- 输入 app 的名字，下一步
- 选择 Web Server Environment -> "Create web server"，下一步
- 选择 platform（Ruby, 2.1 Passenger Standalone)，load balance auto scaling mode，一直下一步
- 选择 "Create an RDS DB Instance with this environment"，下面会要求配置数据库信息，下一步
- "Configuration Details" 不做配置，直接下一步
- 到 "RDS Configuration"， DB engine  选择 postgresql，然后定义用户名和密码，记住这个信息，在配置 Rails App 的系统变量会需要，下一步
- 到 "Permissions" 在 instance profile 选择之前创建好的 profile 名字，在 service role 选项下选择新建，安装页面的指示新建 role
- Review 配置，完成创建

如果顺利 AWS 应该会在几分钟内把 EC2，auto scaling service，load balancer 和 RDS 搭建好。可以在 Beanstalk 的主页面上面看到新建的项目，在项目的 Dashboard 查看安装情况。同时在 Configuration 可以看到已经安装的服务，以下是我创建后看到的页面，点击进去可以看到某项服务的详细配置。

<div>
  <img style="width:750px" class="graf-image" src="{{ site.url }}/assets/images/beanstalk_dashboard.png">
</div>

**EB init & EB setup**

经过上一步，运行 Rails 的服务器，数据库都创建好了，现在需要把 codebase 关联到服务。具体的步骤在这个[文档](http://docs.aws.amazon.com/zh_cn/elasticbeanstalk/latest/dg/eb3-init.html)中描述得很清楚，这里不再赘述。只是在第二步的时候不要选择[ Create new Application ]这个选项，而是选择在上一步中创建的 Application。运行结束了会在 .gitignore 中插入下面信息，同时创建 .elasticbeanstalk 文件和 config 文件，git commit 这些文件。

```code
# Elastic Beanstalk Files
.elasticbeanstalk/*
!.elasticbeanstalk/*.cfg.yml
!.elasticbeanstalk/*.global.yml
```

作为 DevOp，ssh 到服务器是有需要的。Beanstalk 是默认禁用 EC2 的 ssh 机制的。所以需要运行 

```code
eb setup --ssh
```

按照命令行中的提示来操作，AWS 会自动重建运行环境，这可能需要几分钟。重建的进度可以在 AWS -> Web Console -> Beanstalk -> Dashboard 中看到，也可以看到命令行中的输出。一旦命令执行完成，则运行 eb ssh 就可以远程登录到 EC2 服务器上，登录的用户可以 sudo 任何命令。

**配置 database 和 环境变量**

在部署之前，还需要配置数据库的信息。Beanstalk 在创建 Web 环境的时候，会把 App 自动关联到 RDS 的服务数据库（具体如何做到的我也很好奇）。在 RDS 的 Dashboard 可以看到新创建的数据库 instance 的，如下图所见：

<div>
  <img style="width:750px" class="graf-image" src="{{ site.url }}/assets/images/rds_info.png">
</div>

那么如何看到数据库中的数据呢？ 可以查看[官方文档](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ConnectToPostgreSQLInstance.html)，我采用了 psql 远程接入，命令如下。但这样是链接不上的，因为远程 db 没有开放外部访问，需要去配置 db instance 的 [Security Groups](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.RDSSecurityGroups.html) 信息，点击上图中箭头的链接，进入配置的页面，如下图：

```code
psql --host=YOUR_DB_HOUSE --port=5432 --username=YOUR_UN --password --dbname=ebdb

# 这样访问会返回 Connect Timeout 的错误。
```

<div>
  <img style="width:750px" class="graf-image" src="{{ site.url }}/assets/images/rds_security_group.png">
</div>

上图显示的是这台 RDS 的服务器的网络访问配置，在 Inbound tab 下配置访问来源控制。默认是只允许 VPC 内 IP 访问，我这里已经配置好了，已开放给所有 IP 地址。如需配置，点击 Edit，在 source 的下拉框里面选择 “Anywhere”，如下图。这时候再去链接 RDS 服务器就没有问题了。

<div>
  <img style="width:750px" class="graf-image" src="{{ site.url }}/assets/images/rds_security_group_2.png">
</div>

接下来是配置 Rails 的 database.yml。Beanstalk 通过环境变量来管理 Web App 的配置信息。把 Production 的 db 配置信息做如下的修改。

```code
# database.yml

production:
  adapter: postgresql
  encoding: unicode
  database: <%= ENV['RDS_DB_NAME'] %>
  username: <%= ENV['RDS_USERNAME'] %>
  password: <%= ENV['RDS_PASSWORD'] %>
  host: <%= ENV['RDS_HOSTNAME'] %>
  port: <%= ENV['RDS_PORT'] %>
```

然后在 terminal 运行下面的命令，在这里输入你项目 db 的配置信息。

>eb setenv RDS_DB_NAME= RDS_USERNAME= RDS_PASSWORD= RDS_HOSTNAME= RDS_PORT=

**配置 Passenger 对应的 Nginx**

我采用了 Passenger Standalone Mode，那么如何支撑 Nginx 的反向代理功能？这里 AWS 没有提供官方的配置文档（估计它不喜欢用户自定义这些服务）。我在 Passenger 的官文中找到了答案，[Nginx configuration template](https://www.phusionpassenger.com/library/config/standalone/intro.html#nginx-configuration-template)。这个文件在

> /opt/elasticbeanstalk/support/conf/nginx_config_healthd.erb

这竟然是一个 erb 的文件，也就是用 ruby 的语法来书写。可以猜测 Beanstalk 会使用一些自动化脚本来读取这个文件，然后生成最终的配置文件。按照我们项目的要求，我需要配置如下信息。需要 sudo 的权限才能编辑这个文件。修改完成保存，需要重启 passenger 的服务才能使得修改被执行。

{% highlight ruby linenos%}
  set $public_path '<%= app[:root] %>/public';
  set $root_path '<%= app[:root] %>/front-end/dist';
  set $mobile_root $root_path/mobile;
  set $web_root $root_path/web;

  location / {
    root $web_root;
    if ($is_mobile){
      root $mobile_root;
    }
    index index.html;
  }

  location ~ ^(/assets) {
    root $web_root;
    if ($is_mobile) {
      root $mobile_root;
    }
  }

  location ~ ^/uploads {
    root $uploads_path;
  }

  location ~ ^/(api|sidekiq) {
    passenger_enabled on;
  }

  location /websocket {
    proxy_pass http://localhost:3001;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }
{% endhighlight %}

**创建 Elastic Cache - Redis**

现在要配置 Elastic Cache 服务，这份[官文](http://docs.aws.amazon.com/zh_cn/elasticbeanstalk/latest/dg/customize-environment-resources-elasticache.html)中作了详细的介绍。按照步骤来完成，不再赘述。

完成了配置需要做一次部署，运行命令 eb deploy。这个过程会花费更长的时间，因为要创建 redis instance，但也差不多是 5-8 分钟之内。创建完成之后，在 AWS console -> ElasticCache Dashboard -> Cache Clusters 可以看到新创建的 instance。那么如何链接到这个服务呢？按照 AWS 的规定，外网是不能链接到 Cache 的，因为它在 VPC 内网内，只能通过登录 EC2 服务器，然后在 EC2 上访问 Cache 服务。使用 redis-cli 链接的命令如下，官文在[这里](http://docs.aws.amazon.com/AmazonElastiCache/latest/UserGuide/GettingStarted.ConnectToCacheNode.html#GettingStarted.ConnectToCacheNode.Redis)

{% highlight ruby linenos%}
redis-cli -h YOUR_REDIS_ENDPOINT -p 6379
{% endhighlight %}

Redis 的 endpoint 藏得很隐蔽（估计也不希望人为去访问服务），文档在[这里](http://docs.aws.amazon.com/AmazonElastiCache/latest/UserGuide/Endpoints.html)。在 Cache Clusters 的列表页面找到目标 Instance，然后点击 "1 node" 链接，如下图：
<div>
  <img style="width:750px" class="graf-image" src="{{ site.url }}/assets/images/redis_1.png">
</div>

点击进入的页面就能找到 Redis Endpoint 了，如下图：
<div>
  <img style="width:750px" class="graf-image" src="{{ site.url }}/assets/images/redis_2.png">
</div>

回到自己的 Rails 应用，记住修改需要关联到 Redis 的服务的访问链接，如 Sidekiq 和 WebSocket。

**配置启动 sidekiq，Websocket 的 任务**

最后是如何启动 sidekiq 和 WebSocket Server。没使用 AWS 之前，通过 Cap 的 hook method 可以轻松做到，在 AWS 上是用 Custom Command 的[机制](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/customize-containers-ec2.html)。简单来说也是一个 hook 的机制。但是其中有不少的限制，比如 container_commands，官文介绍是：

>The commands in container_commands are processed in alphabetical order by name. They run after the application and web server have been set up and the application version file has been extracted, but before the application version is deployed.  

意思是说这个命令按照文件的英文字母表顺序执行（有顺序之分）。这些命令在应用代码被传到 AWS 和解压之后，但是在应用部署之前（AWS 会把代码传输到一个 tmp 的文件夹，然后解压和运行一些 default 的 hook，最后才做部署）。也就是说，启动 sidekiq 和 websocket server 不应该使用 container_commands。而应该在部署完成后，也就是一个 "Post-Deploy" 的环节。

解决方法参考了 StackOverflow 上的这个[问题](http://stackoverflow.com/questions/31056054/sustainable-solution-to-configuring-rails-sidekiq-redis-all-on-aws-elastic-bea)。简单说是使用 files 这条命令，先生成启动文件（sidekiq.conf），然后调用 “initctl reload-configuration”，这样就可以启动 sidekiq。启动 WebSocket 的办法是创建一个 post script，在 AWS 默认的 post scripts 的文件夹里：

>/opt/elasticbeanstalk/hooks/appdeploy/post/YOUR_BASH_SCRIPT_NAME

这样在每次部署之后，AWS 都会运行这个文件中的脚本，这样就启动了 WebSocket Server。

完成这步之后再做一次 eb deploy，那么整个迁徙过程就完成了。

**其他**

其事整个迁徙过程很不顺利，一是自己不熟悉 AWS 的服务和环境，二是 AWS 入中国后一些服务受到限制，文档不齐全等，算是摸黑完成了这个过程。这个文章远不算不上完整和正确，因为文中我采用的解决方案很可能是错误的，只是一种 Walk Around。

除了文中提到的文档和资源，还有其他的参考文献如下：

- [如何使用 Files 命令来启动 Sidekiq，日文，代码肯定是能看懂的](http://qiita.com/sawanoboly/items/d28a05d3445901cf1b25)
- [AWS Beanstalk + Rails 的教学贴，帮助很大](https://medium.com/@jatescher/how-to-set-up-a-rails-4-1-app-on-aws-with-elastic-beanstalk-and-postgresql-66d4e3412629#.ksv744qan)

**还有一点，由于某种不可抗原因，AWS 80，8080 端口在中国区是默认不可用的，需要联系客服把自己的网站设置为 Exception。**


<br />
<br />
<br />
<br />



