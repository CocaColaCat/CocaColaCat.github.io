---
title: 使用 GA 做 API 的统计 
layout: post
tags: ['Google Analytic', 'API']
level: 初级
brief: 本文简要介绍如何用 GA 做统计，同时对比现存的 Gem。注意姿势，要不然徒劳无功。
image_url: "/assets/images/ga.png"
---

{{ page.title }}
===

对于分析用户访问习惯和行为，Google Analytic 应该是不二之选。免费，界面友好，功能强大，提供灵活的数据上报接口和报表下载功能，真是用过都说好，安利我光荣。比起自己造轮子和管理访问数据，使用 GA 真的可以省下不少开发和维护成本。但只要依赖外部系统，那么就有学习成本和踩坑风险。本文做为 GA 入门教程，希望读者看完能实现快递对接，少走弯路，在用户分析的康庄大道上大步向前～


**Libraries and SDKs for tracking**

可能是在 GA 项目的开发过程中，谷歌内部分裂出了很多项目小组，每个小组又实现自己一套机制，所以在查找资料的时候，会发现有以下多种上报的接口：

- [analytic.js](https://developers.google.com/analytics/devguides/collection/analyticsjs/#the_javascript_tracking_snippet)
- [gif request](https://developers.google.com/analytics/resources/concepts/gaConceptsTrackingOverview#howAnalyticsGetsData)
- [Measurement Protocol](https://developers.google.com/analytics/devguides/collection/protocol/v1/#getting-started)

第一，二种接口都是客户端上报，就是在每个 html 的文件头中嵌入 [JavaScript tracking snippet](https://developers.google.com/analytics/devguides/collection/analyticsjs/#the_javascript_tracking_snippet)。该脚本的作用就是收集用户的数据，比如停留时间，访问的页面，地理位置等信息，然后通过 get 请求把数据上报到 GA 的服务器。很多的 Gem 都实现了这种方式，开发成本低。但是为什么会有第二种方式呢？我也不清楚。找到一份有关[why-does-google-analytic-request-a-gif-file](http://stackoverflow.com/questions/2083043/why-does-google-analytic-request-a-gif-file)的资料。但第二种方法支持的参数少，同时上报后统计的结果不准确，出现丢失用户地理位置信息的情况。

第三种方法可用任何环境的上报，灵活度更大，支持的参数更多，文档也清晰。因为文档写得相对清晰，我在这里就不赘述，仅帖一些实用链接：

- [构造上报请求的详细文档](https://developers.google.com/analytics/devguides/collection/protocol/v1/reference#integer)
- [各种上报场景的调用例子和参数说明](https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide#enhancedecom)
- [参数说明](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters)

简单来说，客户端上报用第一种方法，服务器端用第三种。第三种方法也是我在项目中采用的。

**实现以上方法的 Gem**

第一种方法就不说了。来说说第二种和第三种。[gabba](https://github.com/hybridgroup/gabba) 这个 Gem 就实现了第二种方法。但就像上文说的，使用这种方法虽然上报了 ip 地址，但是在统计结果中却没有体现出用户的地理位置，有误导之嫌。这个库也很久没有维护了，文档不清晰，慎重使用。

[staccato](https://github.com/tpitale/staccato) 实现了 Measurement Protocol，文档写得很详细，维护情况良好。我在项目中就是从 gabba 转到的 staccato。上报采用了异步的 job 的方式，以下是简单的代码：

{% highlight ruby linenos%}
class GoogleAnalyticJob < ActiveJob::Base
  queue_as :google_analytic_track
  GA_DOMAIN = 'your_domain'

  # 上报到 GA 的后台任务
  #
  # @param args [Hash] 上报的参数，参考 https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#dr
  #        event_type [String]  上报的访问类型，page_veiw/event/transaction
  #        title [String] 页面的标题，web_xxxxx 代表 PC 端的请求，api_xxxxx 代表客户端的请求
  #        path [String]  被访问页面的相对路由
  #        hostname [String] 域名
  #        user_agent [String]
  #        ip [String] ip 地址
  #        uid [String]  user id，组合字符串，格式为 {user_id}_{unix_format_of_last_logined_at}
  #        cid [String]  client id，移动设备的 Device-id
  #        data_source [String] 数据源，只能是 web 或 app，分别代表网页端和移动设备 
  # @example
  # => GoogleAnalyticJob.perform { event_type: 'page_view', title: 'api_events_index', path: '/api/events', ip: '1.1.1.1' }
  #
  def perform(args={})
    event_type = args[:event_type]
    case event_type
    when 'page_view'
      ga_with_staccato(args)
    else
    end
  end

  # 试用 staccato 上报，https://github.com/tpitale/staccato。这种方法
  # 遵照了 Google Messaurement Protocol，支持的参数更多，文档更清晰。
  #
  def ga_with_staccato(args)
    tracker = Staccato.tracker(Settings.google_analytic.tid, args[:cid])
    pv_params = { path: args[:path] }
    pv_params[:hostname] = GA_DOMAIN
    pv_params[:title] = args[:title]
    pv_params[:user_ip] = args[:ip]
    pv_params[:user_id] = args[:uid]
    pv_params[:client_id] = args[:cid]
    pv_params[:user_agent] = args[:user_agent]
    pv_params[:data_source] = args[:data_source]
    tracker.pageview pv_params
  end
end
{% endhighlight %}

**小总结**

这篇文章简要介绍了 GA 上报的接口和支持的 ruby 库，算是一个入门。GA 还有强大的 event 和电商数据上报机制，后续有机会再补上。

<br />
<br />
<br />






