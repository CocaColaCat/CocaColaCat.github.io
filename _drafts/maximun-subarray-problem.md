---
title: the maximun subarray problem
---

#### the maximun subarray problem
问题： 给定一个有负数的整数数组，找到数组中和最大的子数组
解决：用分治法 (divide and conquer)
把数组对半分，找到左边最大的子数组，找到跨越中间的最大的子数组，找到右边最大的子数组，对比
需要用到 recurrence

```ruby
def find_max_crossing_subarray(inputs, left_index, mid_index, right_index)
  left_start = 0
  left_sum = -Float::INFINITY
  mid_index.downto(left_index) do |i|
    sum += inputs[i]
    if sum > left_sum
      left_start = i
    end
  end

  
end
```
