---
title: AngularJS testing
---

**TL,DR;**

本文记录了如何一步一步的配置 AngularJS 的 unit 和 [e2e](https://docs.angularjs.org/guide/e2e-testing) 测试环境。AngularJS 的测试会用到 [protractor](https://angular.github.io/protractor/#/), [karma](https://karma-runner.github.io/0.12/index.html), jasmine, PhantomJS, ghost driver, selenium 等库。文中会简要的描述它们之间的关系。希望读者可以参考本文顺利搭建测试环境，少走弯路。

** 原理 **
服务器端的测试会有框架自带的轻量级 server，那么前端的代码如何自动化测试呢？这就需要一个浏览器。前端测试可以运行在主流的浏览器中，如 chrome，ie，firefox 等。还能运行在 headless browser PhantomJS 中。headless 也就是指没有图形界面的，可以用在 vanilla 的测试服务器中。但由于 headless 仅是模拟真实的浏览器，也就意味着它不能验证真实的运行环境，失去了一定的可信度。

有了浏览器不代表测试会自动的跑起来，还需要 browser driver，比如 chrome 的 chrome drive，PhantomJS 的 ghost driver。除了 driver，还需要有调用它们的组件和测试代码。这里起到链接器的组建就是 selenium 了（文主第一次接触 selenium 的时候，感觉它好强大，也对那些坚持自动化测试的人尊敬不已）。


那到底程序员编写好的测试代码是如何被运行起来的呢？

** 搭建 unit 测试环境 **





#### References

- [protractor 入门的 slides, 很棒](http://ramonvictor.github.io/protractor/slides/#/1)
- [offical docs, 全面](https://github.com/angular/protractor/tree/master/docs)
