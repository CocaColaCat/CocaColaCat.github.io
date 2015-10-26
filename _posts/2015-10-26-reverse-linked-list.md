---
title: 链表翻转
layout: post
tag: Algorithm
level: 入门
brief: 通过‘头插入’法实现链表的翻转。要求不能申请新的空间，时间复杂度是 Θ(n)。
image_url: "/assets/images/math.png"
---
#{{ page.title }}

给定一个链表 
>1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9

实现算法把链表从第 m = 2 位到第 n = 6 位之间的数字进行反转，变成：

>1 -> 6 -> 5 -> 4 -> 3 -> 2 -> 7 -> 8 -> 9

实现的过程中不可以申请新的内存地址，时间复杂度是 Θ(n)。

首先是让链表空转 m - 1 位，设定 pHead = 2, 然后让 pPre = 3，也就是会变成最后一位的数字。pCur = 4，这是马上要变成 pHead 下一位的数字。完成 pCur 和 pPre 位置的变换，然后让 pCur 变成一下位，直到 n = 6。
过程图如下：

<div style="max-width: 500px; max-height: 388px;margin: 0px auto 0px auto; border-radius: 2px">
    <img class="graf-image" src="{{ site.url }}/assets/images/reverse_linked_list.png">
    <div>
        <p style="font-size: 9px;text-align: center;text-decoration: underline;color: grey"></p>
    </div>
</div>

下面是实现的代码：

{% highlight c linenos%}
#include <stdlib.h>
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

void rotate(SNode *pHead, int m, int n){
  SNode *pCur = pHead->pNext;
  int i = 0;
  for(;i<m-1;i++){
    printf("index is%i\n", i);
    pHead = pCur;
    pCur = pCur->pNext;
  }

  SNode *pPre = pCur;
  pCur = pCur->pNext;

  n--;
  SNode *pNext;
  for(;i<n;i++){
    pNext = pCur->pNext;
    pCur->pNext = pHead->pNext;
    pHead->pNext = pCur;
    pPre->pNext=pNext;
    pCur=pNext;
  }
}

// given 1→2→3→4→5, m=2,n=4, return 1→4→3→2→5
int main(){
  int m = 3;
  int n = 6;

  SNode *list = create(0);
  SNode *tail = list;
  for(int i=1;i<9;i++){
    tail->pNext = create(i);
    tail = tail->pNext;   
  }

  print(list);
  rotate(list,m,n);
  print(list);
}
{% endhighlight %}

<br />
<br />
<br />
<br />