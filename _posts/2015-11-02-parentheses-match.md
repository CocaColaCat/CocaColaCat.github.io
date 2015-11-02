---
title: 括号匹配问题
layout: post
tag: Algorithm
level: 入门
brief: 给定一个只有括号的字符串，判断这个字符串是不是闭合的。
image_url: "/assets/images/math.png"
---
#{{ page.title }}

给定仅有括号的字符串，如：
>( { } ) [ ( ) ] 

判断这些括号是不是都闭合了（有左括号就有右括号匹配）。以上括号就是闭合的，但如下就是不闭合：

>( { } ) ( ) ] 

借助 stack 的属性就很好处理这个问题。stack 是先进后出（first in last out)。所以对于字符串中的每一个括号，如果是左括号就直接入栈，如果是右括号，就和栈顶元素做对比。如果是匹配的右括号，就让栈顶元素出栈。如此循环一直到遍历整个字符串。如果最终栈是空，那么就说明字符串都闭合了。

{% highlight c linenos%}
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef enum { false, true } bool;

typedef struct tagSNode{
  char value;
  struct tagSNode *pNext;
}SNode;

SNode* create(value){
  SNode *node = malloc(sizeof(SNode));
  node->value=value;
  node->pNext=NULL;
  return node;
}

bool match(char top, char key){
  if(top == '('){
    return ((key == ')') ? true : false);
  }else if(top == '{'){
    return ((key == '}') ? true : false);
  }else if(top == '['){
    return ((key == ']') ? true : false);
  }else{
    return false;
  }
}

void verify(char *str){
  int size = (unsigned int)strlen(str);
  printf("%i\n", size);
  SNode *head = create('&');
  SNode *cur = create(str[0]);
  head->pNext = cur;

  for(int i=1;i<size;i++){

    if(str[i] != cur->value){
      if(match(cur->value,str[i])){
        cur = NULL;
        cur = head;
      }else{
        cur->pNext = create(str[i]);
        cur = cur->pNext;
      }
    }else{
      cur->pNext = create(str[i]);
      cur = cur->pNext;
    }
  }
  if(cur->value == '&'){
    puts("match!");
  }else{
    puts("no match!");
  }
};

int main(){
  char str[] = "()(){}((({{[]";
  verify(str);
}
{% endhighlight %}

<br />
<br />
<br />
<br />