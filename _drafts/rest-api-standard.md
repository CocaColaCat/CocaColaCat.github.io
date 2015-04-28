---
title：REST API 简要开发规范
---

## REST API 简要开发规范

#### 简述
以下文档简要规划了开发 REST API 需要注意的方面。

主要包括了开发的技术栈，文档的编写规范，简单的开发样例描述和测试覆盖的需求。

#### Technology Stack
这个小结列举开发的技术栈，包括以下：

- Framework：rails-api
- Response Format：JSON
- Auth：Token based Auth(JWT), CanCan
- DB：PostgreSQL, Redis
- Testing：RSpec, factory_girl
- Others：Sidekiq, websocket-rails, qiniu

#### 文档规范
按照 REST API 开发的规范，开发的重点在于对资源和返回内容的定义，所以文档需要配合实现一起定义。

文档的规范分为以下几个方面：

- 命名：资源名字（单数).md, 存放在 root_dir/docs/api 之下
- 内容：需要定义资源的性质，以及对应的 actions 

以账户这个资源为例子做简要的描述：

#### 开发样例
#### 测试覆盖

