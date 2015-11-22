---
title: 微信用户访问统计及渠道推广力统计
layout: post
tag: ['Active Admin', 'WeChat', 'Impressionist']
level: 中级
brief: 结合使用 active admin, impressionist 和 微信的 openid，实现在微信浏览器下的访问统计模块。
image_url: "/assets/images/wechat.jpg"
---
#{{ page.title }}

####背景和需求
加入访问统计模块，完成用户行为的分析，是面向 C 端用户必不可少的功能。现在市面上也有不少现成的访问监控统计工具，如百度统计和 Google 分析，都提供了很不错的功能。不过短板在于，百度统计定制化程度低，展示数据不够直接，不能直接满足市场运维人员的查看分析需要。谷歌问题是被墙，访问不方便。因此有必要内部开发这样的模块。分析下来，原理和实现都不困难，获得的效果也很显著。

**需求如下：**

- 针对不同的功能，分别统计该功能下的推广页（首页）PV，UV，新用户UV，以及其他跳转页面的访问情况
- 统计不同功能的用户转发，分享，取消转发情况
- 便于给新功能添加访问统计模块
- 提供可视化界面来实时查看各功能下的用户访问情况

####设计和技术选型
按照上面提出的需求，可以转化为下面的用例(User Story)：

- 记录用户的每次访问，需要知道用户访问是什么功能，访问时间，上游链接，访问参数
- 记录用户对自有公众号的关注情况（仅针对微信用户）
- 实现统计的算法和统计数据的展示

由于功能都限制在微信浏览器下使用，因此借助 [微信授权机制](http://cocacolacat.github.io/2015/04/26/wechat-base_auth.html) 来创建系统用户。在这里需要定义用户模型：visitor，这个模型目前仅保存了用户的微信 openid，后期有需要可以添加更多属性。

那么如何保存用户的访问记录呢？可以使用 [impressionist](https://github.com/charlotte-ruby/impressionist)。它把访问数据存到一个叫做 impression 的模型中，属性包括了：controller_name，action_name（这两个属性可以用来确定用户访问的是哪个功能），request_hash，session_hash，ip_address，message，referrer，params（访问的参数）。满足了目前我们保存数据的需求。不过它也有短板，在后面会提到。

<div style="max-width: 500px; max-height: 388px;margin: 0px auto 0px auto; border-radius: 2px">
    <img class="graf-image" src="{{ site.url }}/assets/images/impression-visitor.png">
    <div>
        <p style="font-size: 9px;text-align: center;text-decoration: underline;color: grey">用户－访问记录</p>
    </div>
</div>

界面的展示借助了 [active admin](https://github.com/activeadmin/activeadmin) ，定制化程度高，上手快，view DSL 够用。下图是最后出来的效果。统计了整体的访问情况和最近一周的数据。

<div style="max-width: 900px; max-height: 388px;margin: 0px auto 0px auto; border-radius: 2px">
    <img class="graf-image" src="{{ site.url }}/assets/images/active-admin.png">
    <div>
        <p style="font-size: 9px;text-align: center;text-decoration: underline;color: grey">各个功能的访问情况</p>
    </div>
</div>

####实现 controller 层逻辑
考虑到这是一个通用功能，是属于 before_action 的行为，所以把逻辑提出到一个 controller concern 中。

{% highlight ruby linenos%}
# 在控制器中调用
class FeatureController < ApplicationController
  include Concerns::ImpressionConcern
  before_action :checkin_wechat_visitor # 识别当前微信用户
  before_action :trace_wechat_visitor, only: [:index] # 仅记录 index 的访问
end
{% endhighlight %}

下面是在 concern 中的逻辑，主要是实现微信用户识别和记录访问请求。
{% highlight ruby linenos%}
# controllers/concern/impression_concern.rb
def checkin_wechat_visitor # 需要通过微信用户的 openid 来识别用户
  if !(session.has_key?(:openid) && session.has_key?(:subscribe))
    redirect_to wechat_authorize_url(authentication_check_subscription_url) and return
  end
  checkin
end

def trace_wechat_visitor # 记录用户访问情况
  impressionist(visitor, impression_message) and return if visitor
end

private
  def checkin
    @visitor = Visitor.find_or_create_by(openid: session[:openid])
    @subscribe = session[:subscribe]
  end
{% endhighlight %}

####实现 active admin 逻辑
首先使用 active admin [Arbre](https://github.com/activeadmin/activeadmin/blob/master/docs/12-arbre-components.md) 中的 panel 和 table_for 来绘制统计表格。在这里 FeatureStatistician 是实现统计算法的模块。通过调用 calculate 方法返回过去 7 的各个指标下的访问情况。再传递到 table_for 中实现遍历输出。当有其他的功能模块需要统计的时候，就是添加一个新的 panel 和对应的 Statistician 就行。
{% highlight ruby linenos%}
# models/admin/dashboard.rb
panel "速查统计" do
  statistician = Utilities::Admin::FeatureStatistician.new
  stat = statistician.calculate
  table_for stat do
    column "日期" do |item| 
      item[:captain].is_a?(String) ? item[:captain] : item[:captain].strftime("%Y-%-m-%d")
    end
    column "PV" do |item| item[:page_view] end
    column "UV" do |item| item[:wechat_visitor] end
    column "新用户(未关注)" do |item| item[:unsubscribe_visitor] end
    column "点击收藏" do |item| item[:click_collect_count] end
    column "查看收藏夹" do |item| item[:click_collection_count] end
    column "转发朋友" do |item| item[:friend_share_count] end
    column "转发朋友圈" do |item| item[:circle_share_count] end
    column "取消转发" do |item| item[:share_cancel_count] end
  end
end
{% endhighlight %}

####实现 Statistician 逻辑
Statistician 中的逻辑很直接，就是提取做数据库的聚合。比如说计算过去 7 天的 PV：
{% highlight ruby linenos%}
# lib/utilities/admin/feature_statistician.rb
def pv_in_last_week
  Impression.where(controller_name: 'feature', action_name: 'index')
    .where("created_at::date >= ?", 7.day.ago.to_date)
    .group("to_char(created_at, 'YYYY-MM-dd')")
    .select("to_char(created_at, 'YYYY-MM-dd') as date, count(id) as count")
    .map{|i| [i.date, i.count] }
end
{% endhighlight %}

####设计渠道推广力统计功能（省略实现）
功能会有不同的渠道合作伙伴进来推广，针对不同的推广方式，需要查看此方式带来的用户访问量。建模是定义了 channel 和 advertisement 两个表格。上面的 UML 图就修改为下图。后期传播出去的 url 都会带上推广方式标示，这样就能识别进入系统是通过哪个渠道。

<div style="max-width: 500px; max-height: 388px;margin: 0px auto 0px auto; border-radius: 2px">
    <img class="graf-image" src="{{ site.url }}/assets/images/ca.png">
    <div>
        <p style="font-size: 9px;text-align: center;text-decoration: underline;color: grey">渠道－推广方式－用户访问记录</p>
    </div>
</div>

####impressionist 的问题
impressionist 增加了 params 字段，可以保存请求携带的参数。在统计过程中往往需要匹配参数。可是 gem 把 params 定义为 text 类型，然后仅是存了序列化的 ActiveSupport::HashWithIndifferentAccess，这样就不能借助 sql 自带的查找方法来做聚合，只能通过 ruby 逻辑。

PostgreSQL 提供了 hstore 机制，可以在 hash 中做查找。若 impressionist 能针对这个做改进会更好。