---
title: Algorithms 复习－merge sort
layout: post
tag: Algorithm
level: 入门
image_url: "/assets/images/math.png"
---

{{ page.title }}
================

###Merge sort 原理和实现

从第二数字开始，和第一个数字对比实现排序。完成这一轮排序，则第二和第一数字按照大小排序。然后到第三个数字，和前面的一，二对比排序。完成这一轮，则前三数字按照大小排序。以此类推，则到最后一个数字完成和前面的数字对比，则排序完成。

Start from the second number, comparing it with the first one. Done and get the first two numbers sorted. Then move to the third number, comparing it with the previous numbers, on by one. Because the previous numbers already in sort, so the current round only need to care about the 'Key' number. For each round complete, there is sorted list numbers. 

{% highlight ruby linenos%}
def insert_sort(inputs)
  length = inputs.length
  return inputs if length <= 0
  for i in 1..(length-1)
    c_index = i
    key = inputs[c_index]
    p_index = c_index-1
    while (p_index >= 0) && (key < inputs[p_index])
      inputs[c_index], inputs[p_index] = inputs[p_index], key   
      p_index -= 1
      c_index -= 1
    end
  end
  inputs
end
{% endhighlight %}

**易错点** 算法相对简单，但是有一点很容易出错。在第 11 行会忘记给 c_index 也向前移动一位，这样会导致交换位置（第 9 行）的时候，总是和初始的元素交换交换，而不是和当前一位交换。


###Insertion Sort 分析

Analyzing an algorithm has come to mean prediting the resource that the algorithm requires. 分析算法就是分析算法占用资源的情况，如内存（memory), 带宽(communication bandwidth)和硬件。一般关注的重点是计算时间（computational time).

Running time 就是算法运行的步数。对算法中的每一行代码的运行次数，计算总和，就是算法的运行时间。运行时间一般有最好情况，最坏情况和平均情况。算法分析的时候一般关注最坏情况，因为：
- 知道最快情况就等于知道最慢的运行时间，不会比这个更差。因此不需要再做无谓的猜测。
- 达到最坏运行时间是普遍情况。

###Rate of Growth（运行时间的增长率）

插入算法的最坏情况是 Θ(n<sup>2</sup>) “theta of n-squared”，最好是 n。



