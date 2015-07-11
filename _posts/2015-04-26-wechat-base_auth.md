---
title: 如何调用微信基础授权实现无登录交互
layout: post
tags: ['Rails', 'WeChat']
level: 中级
brief: 这篇文章简述了如何利用微信的 OAuth2 授权机制，帮助你的网站实现无登录交互体验。
image_url: "/assets/images/wechat.jpg"
---

#{{ page.title }}

####需求

即课平台的用户最近抱怨，微信打开网页，总是要登录，一下子继续使用系统的兴趣就被浇灭了一半。
怎么才能免除用户总是要输入密码用户名（很可能密码也不记得了）的麻烦呢？

####原理

即课平台使用了 token based auth，这个 token 的有效期是 60 天。一般的浏览器不会偷偷的清除
用户的缓存，所以在有效期内用户都不会需要主动登录。可是换到了微信的浏览器，就是另外一个故事。微信浏览器会不定期的（可长可短）清除用户缓存，于是就导致了用户每天都可能需要登录的麻烦。好在微信开发者平台提供了 [网页授权获取用户基本信息](http://mp.weixin.qq.com/wiki/17/c0f37d5704f0b64713d5d2c37b468d75.html) 的接口。这个接口有什么用呢？

这还得简单的提到 OAuth2 这个授权的标准，它定义了不需要泄露登录信息的资源授权解决方案。
假设网站 A 想要从网站 B 获得用户 X 的信息，但是又不能让 A 知道用户 X 在 B 上的登录信息。怎么办？OAuth2 的答案是这样的：

 - 当网站 A 需要获得 X 在网站 B 的信息时候，网站 A 会向 B 发送一个获得信息的请求
 - 网站 B 收到这个请求，就会返回一个让用户授权的页面
 - 如果用户 X 同意授权，那么点击确认的同时网站 B 收到确定，然后把网站 A 请求的信息返回 
 - 如果用户 X 不同意，则网站 A 将得不到任何信息。

这个过程不会泄露用户的登录信息。针对移动端的微信用户，微信也提供了对应的 OAuth2 方法来让开发者获得用户信息。同时微信的 OAuth2 接口分为两种类型（scope)，基础接口和高级接口。基础接口可以获得微信用户的 openid, 这个是不需要用户授权的。高级接口需要用户的授权，可以获得用户的昵称等信息。

那跟议题有什么关系呢？试想如果把即课平台账户和微信账户信息 (openid) 绑定，然后在授权令牌过期的时候，使用微信的 openid 来换取用户的登录令牌，那这样不就实现了无输入登录吗。

####设计

即课平台使用了 ruby on rails, AngularJS，前后端完全分离，这无疑给实现又增加了难度。为了要做到：

- 当客户端没有登录令牌 （缓存被清理）或者令牌过期时，使用绑定的微信 openID 换取用户登录令牌
- 需要把平台账号和微信 openID 绑定

前后端分离的情况下，实现流程图如下：

<!-- <figure class="graf--figure">
  <div class="aspectRatioPlaceholder is-locked" style="max-width: 620px; max-height: 388px;">
    <div class="aspect-ratio-fill" style="padding-bottom: 62.6%;"></div>
    <img class="graf-image" src="{{ site.url }}/assets/images/wechat_oauth.png">
  </div>
</figure> -->

<!-- <figure class="graf--figure">
  <div class="aspectRatioPlaceholder is-locked" style="max-width: 620px; max-height: 388px;">
    <div class="aspect-ratio-fill" style="padding-bottom: 62.6%;"></div>
    <img class="graf-image" src="{{ site.url }}/assets/images/bind_wechat.png">
  </div>
</figure> -->

####实现

以下是客户端的代码。假设用户请求项目列表 （需要授权），run block 会被触发，检测本地是否有授权令牌。

<!-- {% gist CocaColaCat/d76ab10a4ebf08782a99 %} -->

$window.location.href 会触发浏览器改变当前 location，同时发起访问。

{% highlight bash %}
调用 $window.location.href = AuthService.getWechatAuthorizeUrl() 
会如下返回微信 OAuth2 授权 URL
https://open.weixin.qq.com/connect/oauth2/authorize?appid=YOUR_APP_ID&
redirect_uri=YOUR_CALL_BACK_URL&
response_type=code&
scope=snsapi_base&state=any#wechat_redirect
{% endhighlight %}


请求链接需要携带 callback_url, 这是用于当授权结束时，微信知道要往哪里返回授权结果。
这里我们使用的是前端的路由 (为什么要是前端路由)。假设 callback url 是 
>https://www.example.com/#/get_wechat_token?code={微信返回的 code }&state={url_to_projects_list}

那么当微信授权结束（返回code和state）参数，前端 AngularJS 路由表会把 callback 导到 WechatAuthCtrl 处理。微信 code 是用来获取 openid 和 access_token 的令牌，具体参见[文档](http://mp.weixin.qq.com/wiki/17/c0f37d5704f0b64713d5d2c37b468d75.html)。

以下是 WechatAuthCtrl 的处理代码：

{% gist CocaColaCat/144ad175c3ce45d40b4f %}

以下是 AuthToken.get_wechat_token 的处理代码。 angular 想后台发异步请求，返回 promise。

{% gist CocaColaCat/a605bc9c6228031a156f %}

后台又是如何实现的呢？相比前端代码，后台代码逻辑要简单多。

{% gist CocaColaCat/190eb432cf8a2e536c96 %}
