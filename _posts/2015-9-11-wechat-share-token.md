---
title: Yet Another MessageVerifier Usage
layout: post
tag: Rails
level: 中级
brief: 某个月明星稀的夜晚，开发团队上线了引导用户注册的页面，准备大干一场。这个页面制作精良，内容生动有趣，超吴亦凡H5广告十个老罗发布会，让人爱不释手，天使用户看了不分享都对不起朋友，对不起社群。于是他把所有朋友，所有群和朋友圈都转发个遍。现在问题来了，市场团队如何知道谁的转发号召力最强呢，到底是拥有最多朋友的头号天使用户，还是对产品最感兴趣，朋友圈相关性最高的二号天使用户？
image_url: "/assets/images/rails.jpeg"
---
#{{ page.title }}

####tl,dr
解决的关键是建立新用户和推荐人的关联关系。
在每个分享链接里面携带推荐人的用户信息。一旦新用户通过链接完成注册，则通过链接携带的推荐人信息建立推荐关系。这里分享链接的用户信息可以使用 [MessageVerifier](http://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html) 加密用户类型(user_type) 和 用户 ID(user_id)，然后作为参数加入链接。

####解决思路
目标很明确，是需要保存新用户和推荐人的关联关系。可以使用 self-reference 的 modelling。用户模型（User)作为新用户(referred)有且仅有一个推荐人(referee)。而老用户可以是多位新用户的推荐人。如果推荐人是多种用户类型，如学生(Student)互相之间， 老师(Teacher)对学生可以推荐，那么这样的推荐关系需要通过多态 [polymorphic](http://guides.rubyonrails.org/association_basics.html) 的自引用模型来实现。

那么该如何传递推荐人的信息呢？方法一是为每一位用户创建一个全局唯一的 share_token 字段，然后在分享链接里面携带这个 token，于是点击携带 share_token 的分享链接的潜在用户，在创建新账号的时候就可以通过 token 找到推荐人了。
第二种方法是使用 MessageVerifier 来签发用户身份信息作为 share_token。在定位推荐人的时候，只需要验证令牌和读取里面的推荐人信息。 显然第二种更巧妙，减少了额外的数据库字段。

<div style="max-width: 500px; max-height: 388px;margin: 0px auto 0px auto; border-radius: 2px">
    <img class="graf-image" src="{{ site.url }}/assets/images/wechat-share-token.png">
    <div>
        <p style="font-size: 9px;text-align: center;text-decoration: underline;color: grey">多态的用户推荐关系模型 UML 图</p>
    </div>
</div>

####实现
首先是学生，老师和推荐的模型。学生和老师都有多个推荐记录（referrals），而一个新学生只能有一个推荐人（referee）。这里的中间表格 Referral 是为了支持多态而引入的。如果仅仅是学生之间才存在推荐关系，那么不需要这个表。

{% highlight ruby linenos%}
class Student < ActiveRecord::Base
  has_one :referral, foreign_key: 'referred_id'
  has_many :referrals, foreign_key: "referee_id", as: :referee
end

class Teacher < ActiveRecord::Base
  has_many :referrals, foreign_key: "referee_id", as: :referee
end

class Referral < ActiveRecord::Base
  belongs_to :referee, polymorphic: true
  belongs_to :referred, class_name: 'Student'

  validates_presence_of :referee, :referred
  validates_uniqueness_of :referred_id
end
{% endhighlight %}

下面的代码定义了一个单例模式的 TokenGenerator。通过调用 generate_share_token 方法，它可以为某一个用户生成一个 share_token。这个 share_token 含有 "#{user_type}_#{user_id}" 信息，并且使用秘钥签字。
{% highlight ruby linenos%}
module Utilities::TokenGenerator
  include Singleton
  attr_accessor :verifier
  def initialize
    @secret_key = Rails.application.secrets.secret_key_base || "any_key"
    @verifier = ActiveSupport::MessageVerifier.new(@secret_key)
  end

  def generate_share_token(user)
    return "" unless user
    generate("#{user.class.to_s.downcase}_#{user.id}")
  end

  def generate(message)
    Base64.urlsafe_encode64(verifier.generate(message))
  end
end
{% endhighlight %}

同时它可以验证和提取给定 share_token 的用户信息。如验证不通过（token被修改导致无效），则返回 false。
{% highlight ruby linenos%}
# token_generator.rb
def verify(encode_token)
  begin
    decode = Base64.urlsafe_decode64(encode_token)
    verifier.verify decode
  rescue ActiveSupport::MessageVerifier::InvalidSignature => e
    false
  rescue ArgumentError => e
    false 
  end
end
{% endhighlight %}

最终的分享链接如下：
>https://yoursite.com?share_token=QkFoSklnNXpkSFZrWlc1MFh6RUdPZ1pGUmc9PS
0tMDBjMjEzNzMwZmQ5MDA4N2ZkZDZkN2NiYzVkMWIwNDEzNDAyZmNlMw==

{% highlight ruby linenos%}
# 在 ApplicationController 中定义 share_url 需要携带 share_token
# 生成携带推荐人信息的分享链接
def share_url
  share_token = Utilities::TokenGenerator.instance.generate_share_token(current_user)
  share_path(share_token: share_token)
end
{% endhighlight %}

在到达创建这一步之前，用户还可能去其他页面，所以 share_token 会先被保存在 session 里面（此处不展示保存代码）。在创建新用户成功后，调用 set_referral 来建立推荐关系。
{% highlight ruby linenos%}
# 在创建了新用户之后建立推荐关系 #set_referral

def set_referral
  # 获取 share_token 并验证
  return unless share_token = session[:share_token]
  if referee_st = verifier.verify(share_token)
    # 从验证通过的 share_token 中获取用户信息，并还原推荐人
    klass, id = referee_st.split('_')[0], referee_st.split('_')[1]
    referee = klass.classify.safe_constantize.find_by_id(id)
    # 建立推荐关系
    Referral.create(referee: referee, referred: @student)
    # 删除 session 中的 share_token
    session.delete(:share_token)
  end
end
{% endhighlight %}

####最后
遇到需要生成 token 的情景，如激活链接，忘记密码连接等等，都可以使用 MessageVerifier 来解决。
<br />
<br />
<br />
<br />
<br />


