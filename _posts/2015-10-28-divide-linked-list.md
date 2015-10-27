---
title: 链表划分
layout: post
tag: Algorithm
level: 入门
brief: 根据给定的数值，把链表划分为小于数和大于数两部分。要求划分后的两部书链表保持原来的顺序，时间复杂度是 Θ(n)，空间复杂度是 Θ(1)。
image_url: "/assets/images/math.png"
---
#{{ page.title }}

给定一个链表 
>1 -> 2 -> 4 -> 9 -> 3 -> 5

和一个对比数 value = 4, 实现算法把链表划分为大于 4 的部分和小于等于 4 的部分，然后合并起来变成如下：

>1 -> 2 -> 4 -> 3 -> 9 -> 5

题目不难，关键在于熟悉链表的 next 指针。首先定义两个指针，left 和 right，分别用来指向大于 value 的值和小于等于 value 的值。对原链表进行遍历，过程图如下：

<div style="max-width: 500px; max-height: 388px;margin: 0px auto 0px auto; border-radius: 2px">
    <img class="graf-image" src="{{ site.url }}/assets/images/divide_linked_list.png">
    <div>
        <p style="font-size: 9px;text-align: center;text-decoration: underline;color: grey"></p>
    </div>
</div>

这里定义了 leftHead = 0, rightHead = 0，是为了方便书写代码，在最后组合结果的时候会去掉 0。

下面是实现的代码：

{% highlight c linenos%}
#include <stdlib.h>
#include <time.h>
#include <stdio.h>

typedef struct tagSNode{
  int value;
  struct tagSNode *pNext;
}SNode;

SNode* create(value){
  SNode *node = malloc(sizeof(SNode));
  node->value=value;
  node->pNext=NULL;
  return node;
}

void print(SNode *list){
  while(list){
    printf("%i\n", list->value);
    list = list->pNext;
  }
}

void split(SNode *list, int size, int v){
  SNode *p = list->pNext;
  SNode *leftHead = create(0);
  SNode *rightHead = create(0);

  SNode *left = leftHead;
  SNode *right = rightHead;

  while(p!=NULL){
    if(p->value > v){
      right->pNext=p;
      right = p;
    }else{
      left->pNext=p;
      left=p; 
    }
    p=p->pNext;
  }
    left->pNext = rightHead->pNext;
    right->pNext=NULL;
    list->pNext=leftHead->pNext;
}

int main(){
  SNode *list = create(0);
  SNode *node1 = create(1);
  SNode *node2 = create(5);
  SNode *node3 = create(7);
  SNode *node4 = create(8);
  SNode *node5 = create(2);
  SNode *node6 = create(9);
  list->pNext = node1;
  node1->pNext = node2;
  node2->pNext = node3;
  node3->pNext = node4;
  node4->pNext = node5;
  node5->pNext = node6;

  int v = 4;
  print(list);
  split(list, 7, 4);
  puts("after reorder");
  print(list);
  return 0;
}
{% endhighlight %}

<br />
<br />
<br />
<br />