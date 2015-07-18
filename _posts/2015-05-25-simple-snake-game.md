---
title: 用 JS 实现简单的贪吃蛇
layout: post
tag: Algorithm
level: 中级
brief: 实现贪吃蛇是一个很好的练习数据结构和增加对算法理解的途径。不过到底该从哪里开始？模仿是最好老师。文主搜索了现有的贪吃蛇实现（JS, Ruby, C# etc)，找到其中最好的理解的一份实现去分析，然后合上书本，自己摸索出了实现。本文就是对这个合书思考的一个总结。
image_url: "/assets/images/math.png"
---

#{{ page.title }}

####步骤

通过分析这份实现 [贪吃蛇的 JS 实现](http://www.codecademy.com/karapuzz/codebits/CNUPkC/edit)，主要的 functions 包括：

- 游戏面板 (game board)
- 初始化游戏和键盘事件监听
- setInterval 移动蛇事件
- 蛇 (snake)，包括初始化，移动，吃苹果和检测 collision

点击查看流程图
<div class="long_img">
<img src="{{ site.url }}/assets/images/snake_game_flowchart.png" />
</div>


那么如何移动蛇和检测碰撞呢？文主用 array 来存储蛇的身体部分，蛇的移动就是重置蛇头和删除蛇尾的计算，也就是 array pop 和 unshift。首先是按照当前的方向和旧蛇头计算出新的蛇头，然后实现替换。

{% highlight javascript linenos %}
function Snake(startX, startY){
  this.move = function(){
    gameBoard.clearBody();
    newHead = this.getNewHead();
    bodyParts.pop();
    bodyParts.unshift(newHead);
    gameBoard.drawBody();
    this.checkCollision();
  };
  this.getNewHead = function(){
    currentHead = this.head();
    switch(moveDirection){
      case 'right':
        return new BodyPart(currentHead.xPos+8,currentHead.yPos,moveDirection);
        break;
      case 'left':
        return new BodyPart(currentHead.xPos-8,currentHead.yPos,moveDirection);
        break;
      case 'up':
        return new BodyPart(currentHead.xPos,currentHead.yPos-8,moveDirection);
        break;
      case 'down':
        return new BodyPart(currentHead.xPos,currentHead.yPos+8,moveDirection);
        break;
    }
  };
}
{% endhighlight %}

在每次移动之后都需要检测碰撞。首先是检测蛇是否碰到了墙壁，然后是蛇是否碰撞到自己身体。一旦检测到碰撞，结束游戏。

{% highlight javascript linenos%}
function Snake(startX, startY){
  this.checkCollision = function(){
    if (this.head().xPos < 0 || this.head().xPos > 392 || 
        this.head().yPos < 0 || this.head().yPos > 392){
      endGame();
      clearInterval(gameExecutor);
      alert('crash on border, game end');
    }
    for (var i = 1; i < this.length(); i++) {
      if (this.head().xPos == bodyParts[i].xPos && this.head().yPos == bodyParts[i].yPos)
      {
        snakeCrashHandler();
      }
    };
  };
}
{% endhighlight %}

整个实现都按照从外到内的方式来一步步实现，也就是先考虑画出游戏面板，然后是监听鼠标事件，蛇身体的移动，蛇吃水果，检测蛇碰撞。这样的思路会让开发变得直接和简单。

后续需要改善的地方：

- 尝试用单链表的数据结构来存储蛇的身体
- 蛇在后退的时候会出现 bug， 需要改善 

<br />

