
def quicksort(inputs, lo, hi)
  if (lo < hi)
    mi = partition inputs, lo, hi
    quicksort inputs, lo, mi-1
    quicksort inputs, mi+1, hi
  end
  p inputs
end

def partition(inputs, lo, hi)
  key = inputs[hi]
  mi = lo - 1
  unsort = lo
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


quicksort [1, 10, 27, 7, 8, 10, 34, 100, 3, 4, 88, 10, 22, 64, 15], 0, 14