---
title: 少年，不要再让 Timezone 问题搞得你焦头烂额
layout: post
tag: Rails
level: 入门
brief: 原来一直在错误的使用 rails 的时区设置
image_url: "/assets/images/rails.jpeg"
---

#{{ page.title }}

此文仅翻译一篇 2012 年的博文 [The Exhaustive Guide to Rails Time Zones](http://danilenko.org/2012/7/6/rails_timezones/)

https://robots.thoughtbot.com/its-about-time-zones
https://robots.thoughtbot.com/a-case-study-in-multiple-time-zones

Ruby 和 Rails 为 Time 和 Timezone 的使用提供了丰富的工具。但是我发现很多 Rails 程序员都没有注意到这其中的原理，因此导致了诡异的时间配置问题。很常见的情况是程序员在开发环境下不自觉地使用了 '错误'方法，并获得了正确的结果。但是却在生产环境下碰到意想不到的问题。

系统时间(system time)，数据库时间(database time)，应用时间(application time)
系统时间是通过调用 DateTime.now, Time.now 获得。这是 Ruby 的标准库中的方法。这些方法产生的是当前系统的时间，并没有时区的信息，因为它们是脱离 Rails 的方法。
系统时间和时区时间不是一个概念。时区时间是在rails中设置的，也就是用 config.time_zone。如果正好设置得和系统所在时区一样，那么就没有问题，但是如果不同，那么调用 Time.now 和 Time.zone.now 是会有不同结果的。

区分 ruby 的时间方法和rails的时间方法，要不然就会出错。下面这这些是ruby的时间方法：
Time.now
DateTime.now
Date.today
所以想要正确的展示时间，正确的编写时区下的rails代码，就需要有时区的概念，懂得去调用正确的方法。
就比如说服务器上面的时区是 Beijing，但是rails并没有设置时区，所以使用了默认的时区，也就是 utc。因此当创建一个新的时间，使用ruby的方式创建，那么是没有时区信息的。当把这个时间存到db的时候，这个时间会转成utc的时间，也就是8个小时之前。所以数据库里面的考试时间都是utc的时间，也就是错误的时间。思维应该编程我的时区是什么，我要用这个时区的时间来做什么，我从数据库里面拿出来的时区是什么。我本地的时区是什么？我系统的时区是什么。


