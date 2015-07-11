---
title: 一步一步配置 AngularJS 测试环境
layout: post
tags: ['AngularJS', 'Testing']
level: 入门
brief: 本文记录了如何一步一步的配置 AngularJS 的 unit 和 e2e 测试环境。AngularJS 的测试会用到 protractor, Jasmine, PhantomJS, ghost driver, Selenium 等库。文中会简要的描述它们之间的关系。希望读者可以参考本文顺利搭建测试环境，少走弯路。
image_url: "/assets/images/angularjs.jpg"
---
#{{ page.title }}

####原理

服务器端的测试会有框架自带的轻量级 server，那么前端的代码如何自动化测试呢？这就需要一个浏览器。前端测试可以运行在主流的浏览器中，如 chrome，ie，firefox 等。还能运行在 [headless browser PhantomJS](http://phantomjs.org/) 中。headless 也就是指没有图形界面的，可以用在 vanilla 的测试服务器中。但由于 headless 仅是模拟真实的浏览器，也就意味着它不能验证真实的运行环境，失去了一定的真实性。

有了浏览器不代表测试会自动的跑起来，还需要 browser driver，比如 chrome 的 chrome drive，PhantomJS 的 [ghost driver](https://github.com/detro/ghostdriver)。除了 driver，还需要有调用它们的组件和测试代码。这里起到链接器的组建就是 [Selenium](http://www.seleniumhq.org/) 了（文主第一次接触 Selenium 的时候，感觉它好强大，也对那些坚持自动化测试的人尊敬不已）。

以下是 unit 和 e2e 测试的简图。Selenium Server 定义了一套 OOP API，所以任何理解这套 API 的 client 都可以发送测试指令给 Selenium，然后 Selenium 再调动目标浏览器运行测试代码。它强大之处在于 Selenium Server 运行在 A， 可以接收从 B 发来的测试指令，然后 Selenium Server 调用 C 处的浏览器来运行测试。

<!-- ![Alt text]({{ site.url }}/assets/images/karma_test_diagram.png) -->

<!-- ![Alt text]({{ site.url }}/assets/images/protractor_test_diagram.png) -->

####搭建 unit 测试环境

首先是安装 karam 相关的库。假定你使用 npm 做包管理，那么把以下的 dependencies 添加到 package.json 里面。

{% highlight js %}
{
  "name": "MMT",
  "version": "0.0.0",
  "devDependencies": {
    "gulp-karma": "0.0.4",
    "karma": "~0.10",
    "karma-chrome-launcher": "^0.1.4",
    "karma-jasmine": "^0.1.5"
    }
}
{% endhighlight %}

然后运行，后一条指令是按照 karam 的 cli，这样就可以直接调用 karma 而不需要路径。

{% highlight bash %}
$ npm install
$ npm install -g karma-cli
{% endhighlight %}

接着是配置 karma。官网的解释很好，[点击查看](http://karma-runner.github.io/0.12/intro/configuration.html)。下面是文主用的配置文件 karma.conf.js，放在测试文件夹下面。这个配置仅包含最基础的设置，详情查看[官网](http://karma-runner.github.io/0.12/config/configuration-file.html)。

{% highlight js %}
module.exports = function(config){
  config.set({
    autoWatch : true, //自动监测文件变化
    frameworks: ['jasmine'], // 使用 jasmine 做测试框架
    browsers : ['PhantomJS'], // 使用 PhantomJS 做测试浏览器，还可以是 Chrome
    port: 8080,
    // 加载测试脚本和相关的库
    files: [
      // mock 需要的库
      '../src/lib/angular/angular.js',
      '../src/lib/angular-mocks/angular-mocks.js',
      
      // 不要加载的文件
      '../src/lib/**/!(gulpfile|ngAnimateMock|ngMock|ngMockE2E).js',

      // app 
      '../src/app/app.js',
      '../src/app/**/*.js',

      // 测试代码
      'unit/**/*.js',
    ]
  });
};
{% endhighlight %}

这样单元测试的环境就算配置好了。本文就不给出测试例子，请参考 AngularJS 的官网[例子](https://docs.angularjs.org/guide/unit-testing)。最后运行测试

{% highlight bash %}
$ karma start path_to_your_karma_conf_file/karma.conf.js
{% endhighlight %}

####搭建 e2e 测试环境

首先引入相关的库。

{% highlight js %}
{
  "name": "MMT",
  "version": "0.0.0",
  "devDependencies": {
    "gulp-protractor": "^1.0.0",
    "protractor": "^2.0.0",
    "phantomjs":"1.9.16"
    }
}
{% endhighlight %}

npm install。Protractor 需要链接到 Selenium server 才能运行测试，Selenium server 的运行模式有 三种，

- standalone (独立运行，然后通过配置 port 来连通 Protractor 和 Selenium)，
- 让 Protractor 启动 Selenium server
- 链接到远程的 Selenium server

本文关注第二种方法的配置。Selenium 是一个 Java 程序，所以系统需要安装有 Java，以下是在 Mac 上安装的[步骤](https://www.java.com/en/download/help/index_installing.xml)。然后需要下载 seleniumServerJar 文件，这可以通过 protractor 的命令行工具下载。

{% highlight bash %}
$ ./node_modules/protractor/bin/webdriver-manager update
{% endhighlight %}

以下是配置文件 protractor.conf.js， 放在测试文件夹下面。

{% highlight js %}
exports.config = {
  // 存放 seleniumServerJar 的路径
  seleniumServerJar: '../../node_modules/protractor/selenium/
    selenium-server-standalone-2.45.0.jar',

  // 运行 Selenium server 的端口
  seleniumPort: 4444,

  // 测试代码
  specs: [ 'e2e/test.js'],

  // 测试使用的浏览器，这里使用 headless phantomjs
  capabilities: {
    'browserName': 'phantomjs',

    // phantomjs 的路径
    'phantomjs.binary.path': './node_modules/phantomjs/bin/phantomjs',

    // 8910 是 ghost driver 的 端口号
    'phantomjs.cli.args': ['--debug=true', '--webdriver=8910', 
      '--webdriver-logfile=webdriver.log', '--webdriver-loglevel=DEBUG']
  },

  // 测试访问的路由
  baseUrl: 'http://0.0.0.0/',

  framework: 'jasmine',

  jasmineNodeOpts: {
    isVerbose: true,
    showColors: true,
    includeStackTrace: true,
  },
  jasmineNodeOpts: {
    defaultTimeoutInterval: 30000
  }
};

{% endhighlight %}

这样 e2e 测试的环境就算配置好了。本文就不给出测试例子，请参考官网[例子](这样单元测试的环境就算配置好了。本文就不给出测试例子，请参考 AngularJS 的官网[例子](https://docs.angularjs.org/guide/unit-testing)。 最后运行测试

{% highlight bash %}
$ ./node_modules/protractor/bin/protractor ./mobile/tests/protractor.conf
{% endhighlight %}

** 待完成 **

以上教程待改进的地方包括：

- 利用 gulp 来定义测试指令，简化测试执行命令
- 修复一些配置的 bug 

**延伸阅读**

- [Protractor 入门的 slides, 很棒](http://ramonvictor.github.io/protractor/slides/#/1)
- [offical docs, 全面](https://github.com/angular/protractor/tree/master/docs)
- [Selenium WebDriver 原理的介绍](http://www.aosabook.org/en/selenium.html)

