---
title: websocket-rails 的坑
layout: post
tag: [rails, websocket, sidekiq]
level: 初级
brief: websocket-rails 这个 gem 提供了异步推送的封装，可在配合 sidekiq 使用的时候，是否是 standalone 模式会产生不同的行为，引发 bugs。
image_url: "/assets/images/rails.jpeg"
---

#{{ page.title }}

####问题
消耗资源大且慢的系统业务一般会做异步的处理，然后再通过 websocket 推送回给前台。
[websocket-rails](https://github.com/websocket-rails/websocket-rails) 这个 gem 就提供了这样的封装。它的配置很简单，如下:
{% highlight ruby linenos %}
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

上面的配置不同是因为，根据 websocket-rails 的官网说明，非 eventmachine based 的服务器（如 Passenger）必须配置为 standalone = true。
>WebsocketRails can now be started as a standalone server to support non-eventmachine based web servers such as Phusion Passenger. 

在我的情况下开放环境使用了 thin 服务，而 staging 和 production 环境都使用了 Passenger 服务。这样并没有问题，但如果配合异步的处理（如使用 [sidekiq](http://sidekiq.org/)）那就出现问题了。重现的方式如下：

假设你有一个 sidekiq 的 worker 如下

{% highlight ruby linenos%}
class GetThingDoneWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 1
  
  def perform
    get_thing_done
    WebsocketRails[:some_public_channel].trigger(channel_id, { message: "Done!"})
  end
end
{% endhighlight %}

在其他的代码中调用这个 worker如下:
{% highlight ruby linenos%}
GetThingDoneWorker.perform_asyn
{% endhighlight %}

在 standalone = false 的情况下，worker 会被调用，运用 get_thing_done  方法，也会去推送更新，但是在接受端总是不能收到推送。但是在 standalone = true 的情况下就不会出现这个问题。这就是问题。

####后续和原因

第二天再查看 wiki，看到了 [Multiple Servers and Background Jobs](https://github.com/websocket-rails/websocket-rails/wiki/Multiple-Servers-and-Background-Jobs)
文档，才知道如果想用 background job 的话，必须把 config.synchronize = true 设定。
>WebsocketRails supports synchronization between multiple load balanced server instances and the ability to trigger channel events from within background jobs. 

问题就这么解决了。这确实是一个坑。总结来说，在 standalone = false 事，想要在后台作业中推送消息，就需要设置 synchronize 为 true；反之，在 standalone = true 时，并不需要配置。其中的道理或许只能等有时间看源码才知道了。