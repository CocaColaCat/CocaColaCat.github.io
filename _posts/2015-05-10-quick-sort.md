---
title: 快排
layout: post
tag: Algorithm
level: 入门
brief: 快排学习笔记和 Ruby 实现
image_url: "/assets/images/math.png"
---
#{{ page.title }}

在实际中，快排算法被证明是效率最高的对比算法 (Comparison Sort)。最好情况和 merge sort 一样，达到 Θ(nlg<sup>n</sup>)。最差是 Θ(n<sup>2</sup>)。

{% highlight ruby linenos%}
def quicksort(inputs, lo, hi)
  if (lo < hi)
    mi = partition inputs, lo, hi
    quicksort inputs, lo, mi-1
    quicksort inputs, mi+1, hi
  end
end

def partition(inputs, lo, hi)
  key = inputs[hi]
  mi, unsort = lo - 1, lo
  lo.upto(hi-1) do |i|
    if inputs[i] <= key
      mi += 1
      new_value = inputs[i]
      inputs[i] = inputs[mi]
      inputs[mi] = new_value
    end
    unsort += 1
  end
  inputs[hi] = inputs[mi+1]
  inputs[mi+1] = key
  mi + 1
end
{% endhighlight %}

<!-- quicksort [1, 10, 27, 7, 8, 10, 34, 100, 3, 4, 88, 10, 22, 64, 15], 0, 14 -->

