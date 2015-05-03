---
title: Jekyll 吐槽 － 配置 syntax highlight  
layout: post
---

{{ page.title }}
================

<p class="meta">29 Apr 2015 - GZ</p>

都说 Jekyll 大法好，我满怀激情的去尝试，短暂的蜜月期后没想却是漫长的失望期。

设置语法高亮的文档写得不是糟糕可以形容了。

高亮语法的设置竟然分布在两个地方(两个地方，一听就是坑)：

首先是在 [configuration](http://jekyllrb.com/docs/configuration/)。

这里提到了如何延用 markdown triple backticks 的方法做语法高亮。

设置很简单，嗨皮的跟着做（因为官文没有给出样例，我还是 google 一翻才得出以下配置):

```
markdown: redcarpet
highlighter: pygments
redcarpet:
  extensions: ["fenced_code_blocks", "autolink", "tables", "no_intra_emphasis"]
```

嗨皮的打开浏览器，然后就悲剧了。

无论我怎么刷都刷不出样式呀！为什么？google，竟然没有人碰到相同的问题。心想这么简单的事情，没准是自己配置错了。于是朝着这个错误的方向继续排查问题。

文主还有正式工作，只能晚上花些时间去做。在家里翻墙又不给力，所以花了好几天都搞不定这事情。

别提多么难受，吃不香睡不好。

如果读者觉得其实答案很简单，就是没有引用需要的 CSS。

这对于初入一个技术的小白来说，把文档当作圣经，出现问题 google 也找不出问题，怎么会知道？

于是今天实在忍不住了，上班也开始排查原因。又是一顿 googling。

于是发现了官文中有关语法高亮的配置介绍，竟然在另外一个页面：
[templates](http://jekyllrb.com/docs/templates/)

```
Stylesheets for syntax highlightingPermalink

In order for the highlighting to show up, you’ll need to include a highlighting stylesheet. 
```

看到这里, 文主突然是大彻大悟啊。jekyll 敢不敢在 configuration 的文档里面声明这点呀，没有 CSS 肯定不会渲染样式， 这！谁！不！知！道！

懂得的缘由，可还是不懂如果操作呀！ jekyll 没有提你需要用 layout 来引用 CSS 文件， etc...

总之又是一顿 google 才找到解决方案。

结语：

一开始真的很惊艳，github 无限空间写文章，自带版本控制，markdown 语法很友好，等等，蜜月期啊。

没想到被文档给坑了。以后多长个心眼吧，文档不敢全信了。

最后是反鸡汤 FTRTFM (Fuck The 'Read The Fucking Manual）。

好吧，文主也需要反省，其实人家有声明了，谁让你不好好看文档呢。


