---
title: 配置 "Build when a change is pushed to BitBucket"
layout: post
tag: ['Jenkins', 'BitBucket']
level: 无
brief: 利用 webhooks 和 BitBucket Plugin 来实现代码推送后自动触发测试服务器启动测试。自动化测试必须有。
image_url: "/assets/images/jenkins.jpg"
---

#{{ page.title }}

<br />

Jenkins 是一个免费的好用自动化测试服务器，它可以对接主流的 SCM 系统，如 Git, BitBucket。本文记录如何配置 "Build when a change is pushed to BitBucket"，使得推送到 remote code base 的修改可以自动触发测试服务器运行。步骤如下：

- 安装 Bitbucket Plugin。 如果是已经安装过了，记得要更新到最新版本。在 1.1.2 之前有重大的 bug。

>Jenkins Web 界面 -> Manage Jenkins -> Manage Plugins -> Avaliable -> 查找 Bitbucket Plugin 并安装

- 配置目标 Project。其他的 URL 配置在这里就省掉了。

>Jenkins Web 界面 -> 目标 Project -> Configure -> 找到 Build Triggers -> 选择 Build when a change is pushed to BitBucket

- 配置 BitBucket Webhooks

先找到目标项目的配置页面，然后在配置下看到 Webhooks，选择 "Add Webhooks"。

<div style="max-width: 750px;margin: 0px auto 0px auto; border-radius: 2px">
    <img class="graf-image" src="{{ site.url }}/assets/images/bitbucket-webhook-1.png">
    <div>
        <p style="font-size: 9px;text-align: center;text-decoration: underline;color: grey">Bitbucket - Webhooks 配置页面</p>
    </div>
</div>

在创建页面填写 Title, URL。[URL](https://wiki.jenkins-ci.org/display/JENKINS/BitBucket+Plugin) 的格式是 YOUR_JENKINS_URL/bitbucket-hook/ (最后的这个斜杠不能省掉)。如此保存就可以了。
<div style="max-width: 500px;margin: 0px auto 0px auto; border-radius: 2px">
    <img class="graf-image" src="{{ site.url }}/assets/images/bitbucket-webhook-2.png">
    <div>
        <p style="font-size: 9px;text-align: center;text-decoration: underline;color: grey">Bitbucket - Webhooks 配置页面</p>
    </div>
</div>

- 测试

每当有代码提交的时候，bitbucket 就会给以上配置的地址发送一个 POST 请求。Jenkins 在收到请求后会从配置中找到匹配的目标测试项目，如果找到，则启动测试。如下图所示中的最后一个记录就是推送成功了。

<div style="max-width: 500px;margin: 0px auto 0px auto; border-radius: 2px">
    <img class="graf-image" src="{{ site.url }}/assets/images/bitbucket-webhook-3.png">
    <div>
        <p style="font-size: 9px;text-align: center;text-decoration: underline;color: grey">Bitbucket - Webhooks 配置页面</p>
    </div>
</div>


