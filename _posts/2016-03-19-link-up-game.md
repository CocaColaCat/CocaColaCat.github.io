---
title: JS 小游戏之连连看
layout: post
tag: [Game,JavaScript]
level: 中级
brief: 最近在看《编程之美》，第一章的游戏之乐就提到了《连连看》的实现原理，关键在于用到了最短路径算法，正好用 js 实现一个简陋版复习下图算法。
image_url: "/assets/images/game.jpg"
---
{{ page.title }}
===

**动手前的一些思考**

在[《编程之美》](https://book.douban.com/subject/3004255/)中，作者提到微软研究院把连连看变成了一种让同事间互相熟悉的小工具，就是把新同事的脸作为游戏的图片，通过玩游戏就轻松完成了互相熟悉的目的。我觉得这个想法真的是太妙，不由的自己也想学着做一套这样的小工具。可是按照这样的 Spec 来实现，我可能会花费更多的时间在界面和美工上。我的初衷还是要练习算法，所以定了这样的目的：

>快速实现核心算法，理解内在的原理 > 好看的样式和界面

基于这样的目的，我确定了技术栈和一些实现的细节：

- 使用原生 JS，HTML 和 CSS 来实现，快速上手
- 使用颜色块来替代图片

在开始之前，先来个趣味版和简陋版(怎么觉得有点像元素周期表)的对比图：

<div style="float: left">
  <img style="width:300px" class="graf-image" src="{{ site.url }}/assets/images/link_up_1.jpg">
</div>

<div style="margin: 0px auto 0px 20px; border-radius: 2px;float: left">
  <img style="width:450px" class="graf-image" src="{{ site.url }}/assets/images/link_up_2.png">
</div>
<div style="clear: both"></div>

经过实践，实现可以细分为以下的步骤：

- 绘制游戏板
- 随机产生连连看的色块元素
- 识别用户的点击事件，用户点击格子的时候要标记格子
- 实现抵消算法：同色格子之间可以相消除，不管格子之间是否有通路
- 实现抵消算法：同色格子之间必须要有通路才能抵消
- 实现抵消算法：同色格子之间必须在3个转弯之内的通路才可以抵消
- 显示分数
- 处理“死锁”问题（剩余格子没有配对颜色）

好了，没有再多的废话，Don't talk, SHOW ME THE CODE!

**绘制游戏板和随机产生色块**

一开始我用的是 DOM 的方式来绘制游戏板，发现这样的方法需要写很多操作 div 的 js 代码，不甚其烦。于是想到之前写 flappy bird 的时候用的是 Canvas，理论上这次也可以利用这样的技术。快速补习 Canvas 的[基本语法](http://www.w3schools.com/canvas/)。

游戏的设计做了简化，首先游戏是 15 x 11 的格子板，在初始状态下，双数行都是白色格子，也就是可以作为通路的格子；单数行都是彩色格子，是要完成消除作业的格子。作业格子的颜色是从这个 COLORS 数组中随机选择的。

{% highlight javascript linenos%}
var COLORS = ['red','yellow','blue','green','orange','pink'];
{% endhighlight %}

使用一个 Node 的对象来定义格子，这个 Node 的概念也是借用 Graph Theory 中的连接节点。白色的节点是可以连接的，彩色的节点是死路。下面是 Node 的定义。首先它是一个正方形的格子，也就是 width 是固定的。每个格子只需要定义左上点的坐标(coordinate)就能完成格子的绘制。

{% highlight js linenos%}
var Node = function (x,y,isBlank,left,right,up,down,color,src,desc) {
    this.x = x;
    this.y = y;
    this.isBlank = isBlank; // 该格子是否是连通节点的flag，彩色格子的值是 false。
    this.left = left; // 定义该格子的左邻居
    this.right = right; // 右邻居
    this.up = up; // 上
    this.down = down; // 下
    this.color = color; // 颜色
    this.src = src; // 该节点是不是第一次点击的源节点
    this.desc = desc; // 终节点
};
{% endhighlight %}

既然是要绘制一个 15 x 11 的格子图，那么首先想到用一个二维的数组来储存每个格子。下面的代码就是做了一个双循环计算，碰到单数行就创建彩色格子，双数行就创建白色格子。

{% highlight js linenos%}
var lines,
    canvas,
    ctx,
    nodeWidth,
    nodePerRow,
    nodePerColumn;
nodeWidth = 40;
nodePerRow = 15;
nodePerColumn = 11;

function initGrid(){
    lines = new Array(); // 初始化数组
    for(var i=0;i<nodePerColumn;i++){ // 每列 11 个格子
        lines[i] = new Array();
        var x,y,left,right,up,down,isBlank,color;
          for(var j=0;j<nodePerRow;j++){ // 每行 15 个格子
            x = j*nodeWidth;
            y = i*nodeWidth;
            if(i%2==0){ // 双数行都是白色格子
              isBlank = true;
              color = 'white';
            }else{
              isBlank = false; // 单数行是彩色格子
              var index = Math.round(Math.random()*(COLORS.length-1))
              color = COLORS[index];
            }
            var node = new Node(x,y,isBlank,left,right,up,down,color,false,false);
            lines[i].push(node);
          }
        }
    }
}
{% endhighlight %}

有了格子就是绘制。Canvas 的基本用法，用 fillRect 画正方形，然后用 strokeRect 来画边框。

{% highlight js linenos%}
function drawGrid(){
    canvas = document.getElementById('grid');
    ctx = canvas.getContext('2d');
    for(var i=0;i<nodePerColumn;i++){
        for(var j=0;j<nodePerRow;j++){
            var curNode = lines[i][j];
            ctx.lineWidth=1;
            ctx.fillStyle = curNode.color;
            ctx.fillRect(curNode.x, curNode.y,nodeWidth,nodeWidth);
            ctx.strokeStyle = 'grey';
            ctx.strokeRect(curNode.x, curNode.y,nodeWidth,nodeWidth);
        }
    };
}
{% endhighlight %}

这部分全部的代码这里 [linkup step by step 01](https://github.com/CocaColaCat/algorithms/blob/master/src/games/link_up/linkup_sbs_01.html)，出来的效果如上图。

**识别用户的点击事件**

为了让用户知道自己的点击是成功的，在点击第一个格子的时候，加粗格子边框为黑色(Black)，点击第二个格子的时候，加粗边框为褐色(Brown)。

首先是需要定义监听事件，在用户点击了 canvas 的某个点后，要设别出用户点击的是哪个格子。

{% highlight html linenos%}
    // 定义监听事件
    <canvas id='grid' height="440px" width="600px" onclick="q()"></canvas>
{% endhighlight %}

{% highlight js linenos%}
  function q(event) {
    event = event || window.event;
    canvas = document.getElementById('grid'),
         x = event.pageX - canvas.offsetLeft, // 触点的 x 值
         y = event.pageY - canvas.offsetTop; // 触点的 y 值

    var xIndex = parseInt(x/nodeWidth,10),
        yIndex = parseInt(y/nodeWidth,10);
    var clicked = lines[yIndex][xIndex]; // 确认是哪个格子

    if(!srcSet){ // 如果是第一次点击，则此点设为原点
      clicked.src = true;
      srcSet = true;
      srcNode = clicked;
    }else if(srcSet && !descSet){ // 如果是第二次点击，此点设为终点
      clicked.desc = true;
      descSet = true;
      descNode = clicked;
    }
  }
{% endhighlight %}

原点和终点通过 Node.src 和 Node.desc 的属性标记出来，然后在绘制格子的时候根据这个属性来渲染不同的边框。

{% highlight js linenos%}
    if(curNode.src){ // 如果是原点，则渲染黑色边框
      ctx.lineWidth=4;
      ctx.strokeStyle = 'black';
      ctx.strokeRect(curNode.x, curNode.y,nodeWidth-2,nodeWidth-2);
    }else if(curNode.desc){ // 终点则渲染棕色边框
      ctx.lineWidth=4;
      ctx.strokeStyle = 'brown';
      ctx.strokeRect(curNode.x, curNode.y,nodeWidth-2,nodeWidth-2);
    }else{ // 默认是灰色
      ctx.strokeStyle = 'grey';
      ctx.strokeRect(curNode.x, curNode.y,nodeWidth,nodeWidth);
    }
{% endhighlight %}

虽然点击事件触发了重设 node 的属性，但是还需要告诉 js 去重绘格子。这个间歇的自动操作就需要 [window.requestAnimationFrame](http://www.zhangxinxu.com/wordpress/2013/09/css3-animation-requestanimationframe-tween-动画算法/) 方法，简单来说它实现了 setInterval 的功能。下图是点击了原点和终点的效果。

{% highlight js linenos%}
function main(){
    initGrid();
    var loop = function(){
      drawGrid();
      window.requestAnimationFrame(loop, canvas);
    }
    window.requestAnimationFrame(loop, canvas);
}
{% endhighlight %}

<div>
  <img style="width:400px" class="graf-image" src="{{ site.url }}/assets/images/link_up_clicked.png">
</div>
此步的代码在 [linkup step by step 02](https://github.com/CocaColaCat/algorithms/blob/master/src/games/link_up/linkup_sbs_02.html)。

**实现抵消算法 1: 同色相消**

游戏的抵消规则是：是同色可连接（通过白色格子，a.k.a 通道）的格子，同时他们之间的路线要小于等于三个转弯。把这个条件拆分为三个来分步实现：

1. 同色
2. 必须是仅仅通过白色格子连接起来
3. 连接的路线要小于等于三个转弯。

同色相消是很简单的算法：在原点和终点都被点击后去判断原点和终点的 color 属性值是不是相同。如果相同，则把原点和终点变成白色；反之不变。此步的代码在 [linkup step by step 02](https://github.com/CocaColaCat/algorithms/blob/master/src/games/link_up/linkup_sbs_03.html)。

{% highlight js linenos%}
// 在 q() 方法中做判断
if(srcSet && descSet){
  srcNode.color = descNode.color = 'white';
  srcNode.isBlank = descNode.isBlank = true;
  srcNode.src = descNode.desc = srcSet = descSet = false;
}
{% endhighlight %}

**实现抵消算法 2: 同色通路相消**

思路是用最短路径算法找到原点和终点之间的通路。用户在点击了起点和终点后，触发抵消算法。先把起点的非彩色（白色节点）邻点压栈，然后依次对比栈队中的节点是不是就是终点，如果是则结束遍历（深度优先）；如果不是，则把该点的非彩色邻点压栈，然后下一个对象出栈，依此类推，直到栈队为空或者找到终点。这就是典型的深度优先搜索。因为每个节点之间的距离都是相同的，则可以认为这就是最短路径算法的特例。

{% highlight js linenos%}
// 抵消算法
function isMatch(){
  if((srcNode.color == descNode.color)){ // 首先是颜色要相同
    hasPathTo(); // 做深度优先搜索
    if(found){ // 定义了全局变量，初始值是 false。找到终点后设为 true
      drawQueue(); // 绘制连接路线
    }
    return found;
  }else{
    return false;
  }
}
{% endhighlight %}

下面两个图（密恐的读者对不起了）左边是点击起点 (index = 78) 和右图是连接到终点 88 后两个节点抵消，同时渲染它们之间的通路。如果尝试点击 26 和 79，则不能成功。此步的代码在 [linkup step by step 04](https://github.com/CocaColaCat/algorithms/blob/master/src/games/link_up/linkup_sbs_04.html)。

<div style="float: left">
  <img style="width:380px" class="graf-image" src="{{ site.url }}/assets/images/link_up_path_1.png">
</div>

<div style="margin: 0px auto 0px 20px; border-radius: 2px;float: left">
  <img style="width:380px" class="graf-image" src="{{ site.url }}/assets/images/link_up_path_2.png">
</div>
<div style="clear: both"></div>

<br />
**实现抵消算法 3: 转弯计数在三个以内才能抵消**

要求需要在判断两节点颜色相同，相通的同时限制它们之间不能超过 3 个转弯。解决方式是维护一个数组，key 是节点，value 是这个节点和起点之间的转弯计数。同时以下规律成立：

>在查找路径过程中，如果 "当前点" 转移的方向和 "源点" 转移的方向相同，则认为 "当前点" 和 "起点" 之间的转弯数目等于 "源点" 的转弯计数；如果方向不同，则转弯计数加一。

**显示分数**

定义一个 score 的全局变量，如果抵消则加一。


**处理“死锁”问题**

当剩余的有色格子数目小于等于颜色集合数时，进行“死锁”检测。如果剩余的格子都不可以配对了，则对剩余格子重新着色。以上操作成立的前提是全部有色格子总数必须是偶数。

**小总结**

全部的代码在 [linkup](https://github.com/CocaColaCat/algorithms/blob/master/src/games/link_up/link_up.html)，点击 [demo](http://cocacolacat.github.io/static/linkup.html) 可以试玩。本着练习算法的目的来实现这个小游戏，基本完成任务。核心在于深度优先算法，根据这个为切入，整个解决方案就不会跑偏了。

但在实现的时候竟然用了 window.requestAnimationFrame 这样的方法，其实完全没有必要。当时的初衷是自动触发游戏板的重绘，分数的更新。其实这些操作应该在用户点击格子后触发。最终的实现改过来了，但是那些分步的代码没有修改，也不花时间修正了，特此说明。


<br />
<br />
<br />
