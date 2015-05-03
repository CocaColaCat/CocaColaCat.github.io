---
title: 如何调用微信基础授权实现无登录交互
layout: post
---

{{ page.title }}
================

<p class="meta">26 Apr 2015 - GZ</p> 

#### TL;DR

#### 需求
即课平台的用户最近抱怨，微信打开网页，总是要登录，一下子继续使用系统的兴趣就被浇灭了一半。

怎么才能免除用户总是要输入密码用户名（很可能密码也不记得了）的麻烦呢？

#### 原理
即课平台使用了 token based auth，这个 token 的有效期是 60 天。一般的浏览器不会偷偷的清除
用户的缓存，所以在有效期内用户都不会需要主动登录。

可是换到了微信的浏览器，就是另外一个故事。

微信浏览器会不定期的（可长可短）清除用户缓存，于是就导致了用户每天都可能需要登录的麻烦。

好在微信开发者平台提供了 [网页授权获取用户基本信息](http://mp.weixin.qq.com/wiki/17/c0f37d5704f0b64713d5d2c37b468d75.html) 的接口。

这个接口有什么用呢？

这还得简单的提到 OAuth2 这个授权的标准，它定义了不需要泄露登录信息的资源授权解决方案。
假设网站 A 想要从网站 B 获得用户 X 的信息，但是又不能让 A 知道用户 X 在 B 上的登录信息。怎么办？

OAuth2 的答案是这样的：

 - 当网站 A 需要获得 X 在网站 B 的信息时候，网站 A 会向 B 发送一个获得信息的请求
 
```
[site A] --- 我需要用户 X 的昵称，年龄和地址 ---> [site B] 
```

 - 网站 B 收到这个请求，就会返回一个让用户授权的页面

```
[site B] --- 你同意网站 A 获取你这些信息吗？ ---> [user X]
```
 
 - 如果用户 X 同意授权，那么点击确认的同时网站 B 收到确定，然后把用户 A 请求的信息返回
 
```
[user X] --- 同意 ---> [site B] --- 用户的昵称，年龄和地址 ---> [site A]
```
 
 - 如果用户 X 不同意，则网站 A 将得不到任何信息。

```
[user X] --- 不同意 ---> [site B] --- 拒绝 ---> [site A]
```

这个过程不会泄露用户的登录信息。

针对移动端的微信用户，微信也提供了对应的 OAuth2 方法来让开发者获得用户信息。

同时微信的 OAuth2 接口分为两种类型（scope)，基础接口和高级接口。基础接口可以获得微信用户的 openid, 这个是不需要用户授权的。高级接口需要用户的授权，可以获得用户的昵称等信息。

那这个议题有什么关系呢？

试想如果把即课平台账户和微信账户信息 (openid) 绑定，然后在授权令牌过期的时候，使用微信的 openid 来换取用户的登录令牌，那这样不就实现了无输入登录吗。

#### 设计

即课平台使用了 ruby on rails, AngularJS，前后端完全分离，这无疑给实现又增加了难度。

为了要做到：

- 当客户端没有登录令牌 （缓存被清理）或者令牌过期时，使用绑定的微信 openID 换取用户登录令牌
- 需要把平台账号和微信 openID 绑定

前后端分离的情况下，实现流程图如下：

![通过微信 openid 换取平台授权令牌]({{ site.url }}/assets/images/wechat_oauth.png)

![平台账号绑定微信 openid ]({{ site.url }}/assets/images/bind_wechat.png)

#### 实现

以下是客户端的代码。假设用户请求项目列表 （需要授权），run block 会被触发，检测本地是否有授权令牌。

 ```javascript
angular.module('app',[])
.config([, function(){

   //项目列表路由
   .state('projects',{
      url:'/projects',
      templateUrl:"app/project/ProjectList.html",
      controller:"ProjectListCtrl",
      access:{requireLogin:true}
    })

    .state('get_wechat_token',{
      url:"/get_wechat_token?code",
      controller:"WechatAuthCtrl",
      access:{requireLogin:false}
    })

}])
.run(["$rootScope", "$window", "$state", "AuthService", function($rootScope, $window, $state, AuthServic) {
    $rootScope.$on("$stateChangeStart", function(event, nextRoute, currentRoute){
        // 请求的路径要求登录同时没有授权令牌
        if( nextRoute.access.requireLogin &&
            !AuthService.is_logined() &&
            !AuthService.initCheckToken()) {
          event.preventDefault();
          // 只针对微信浏览器
          if (AuthService.isWechatBrowser()){ 
           // 尝试通过 openid 换取用户登录令牌
           $window.location.href = AuthService.getWechatAuthorizeUrl();
          }else{
            $location.path("/login");
          }
        }
    });
}
 ```

$window.location.href 会触发浏览器改变当前 location，同时发起访问。

```
$window.location.href = AuthService.getWechatAuthorizeUrl();
返回微信 OAuth2 授权 URL
https://open.weixin.qq.com/connect/oauth2/authorize?appid=YOUR_APP_ID&redirect_uri=YOUR_CALL_BACK_URL&response_type=code&scope=snsapi_base&state=any#wechat_redirect
```

请求链接需要携带 callback_url, 这是用于当授权结束时，微信知道要往哪里返回授权结果。
这里我们使用的是前端的路由 (为什么要是前端路由)。

假设 callback url 是 https://www.example.com/#/get_wechat_token?code={微信返回的 code }&state={url_to_projects_list}

那么当微信授权结束（返回code和state）参数，前端 AngularJS 路由表会把 callback 导到 WechatAuthCtrl 处理。微信 code 是用来获取 openid 和 access_token 的令牌，具体参见[文档](http://mp.weixin.qq.com/wiki/17/c0f37d5704f0b64713d5d2c37b468d75.html)

以下是 WechatAuthCtrl 的处理代码：

```javascript
angular.module('app.account')
.controller('WechatAuthCtrl', ['$scope', '$location','AuthService', 'Account', 'AuthToken', 'jwtHelper',
  function($scope, $location, AuthService, Account, AuthToken, jwtHelper) {
    // 获取返回参数 code 和 state
  var code = $location.search().code;
  var state = $location.search().state;

  // 通过 code 来获得签名的 openid
  var respond = AuthToken.get_wechat_token(code, state);
  respond.then(function(data){
    // 处理 2XX 回复

    // 获取授权令牌
    var auth_token = data.auth_token;

    // 获取签名微信 openid
    var wechat_token = data.wechat_token;
    var account_id = undefined;

    // 如果有授权令牌，存令牌，load 用户信息，转到 state 声明的路由
    if (auth_token != undefined){
      account_id = jwtHelper.decodeToken(auth_token).id;
      Account.getById(account_id).then(function(account) {
        AuthService.login(data, account);
        if(state != ""){
          $location.path(decodeURIComponent(state));
        }else{
          $location.path('/projects');
        }
      })
    } 
    else{
      // 没有授权令牌，说明没有绑定到微信 openid，存微信令牌用于后面的绑定
      AuthService.storeWechatToken(wechat_token);
      $location.path("/login");
    }
  },function(data){
    $location.path("/login");
  });
}])
```

以下是 AuthToken.get_wechat_token 的处理代码。 angular 想后台发异步请求，返回 promise。

```javascript
angular.module('app.resource')
.factory('AuthToken', ['BaseResource', '$http', 'API_ENDPOINT', '$q', function (BaseResource, $http, API_ENDPOINT, $q) {
    var AuthToken =  BaseResource("auth_token");

    AuthToken.get_wechat_token = function(code, state){
        var deferred = $q.defer();
        // 构造 url
        var get_wechat_token_url = API_ENDPOINT + "/get_wechat_token?code=" + code + "&state=" + state;

        // 发送 get
        $http.get(get_wechat_token_url).then(function(data){
            deferred.resolve(data.data);
        }, function(data){
            deferred.reject(data.data);
        })
        return deferred.promise;
    }
    return AuthToken;
}]);
```

后台又是如何实现的呢？相比前端代码，后台代码逻辑要简单多。

```ruby
class Api::V1::AuthTokenController < ApplicationController
  include Concerns::AuthTokenConcern
  include Concerns::WechatAuthConcern

  def get_wechat_token
    // 通过 code 来获取 openid
    openid = App::AuthProcessor.get_wechat_openid params[:code]

    if openid
      // 通过 openid 匹配平台账户
      binded_account = Authorization.fetch_wechat_account_by openid

      // 生成签字的 openid 令牌
      response_body = { wechat_token: App::AuthProcessor.get_wechat_token(openid, binded_account) }

       // 如果能找到平台账户，生成授权令牌
      response_body.merge!(auth_token: create_jwt(binded_account)) if binded_account

      // 返回
      render json: response_body, status: :created
    else
      // 处理没有 openid 的异常
    end
  end

end

require 'httparty'
module App
    class AuthProcessor

        // 获取用户的 openid
        def self.get_wechat_openid(code)
          response = HTTParty.get get_openid_url(code)
          JSON.parse(response.body)['openid']
        end

        // 构造获取 openid 的链接
        def self.get_openid_url(code)
          url_params = {
            appid: JSSDKAPPID,
            secret: get_wechat_api_secret,
            code: code,
            grant_type: "authorization_code"
          }
          get_openid_url = "https://api.weixin.qq.com/sns/oauth2/access_token?"
          get_openid_url += concat_params(url_params)
        end

        // 生成签字的 openid 令牌
        def self.get_wechat_token(openid, binded_account=nil)
          secret_key = get_app_secret_key
          payload = { openid: openid }
          payload.merge!(account_id: binded_account.id) if binded_account
          JWT.encode(payload, secret_key)
        end

        def self.get_app_secret_key
          Rails.application.secrets.secret_key_base
        end

        def self.get_wechat_api_secret
          Rails.application.secrets.wechat_api_secret
        end

        def self.concat_params(params)
          params.flat_map.inject("") { |result, k_v| result += "#{k_v.first}=#{k_v.last}&"; result }[0..-2]
        end
    end
end
```


{% highlight ruby %}
def show
  @widget = Widget(params[:id])
  respond_to do |format|
    format.html # show.html.erb
    format.json { render json: @widget }
  end
end
{% endhighlight %}












 
