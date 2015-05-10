def quick_sort(inputs, lo, hi)
	if (lo < hi)
		mi = partition inputs, lo, hi
		quick_sort inputs, lo, (mi-1)
		quick_sort inputs, (mi+1), hi
	end
	p inputs
end


def partition(inputs, lo, hi)
	mi = lo - 1
	key = inputs[hi]

	lo.upto(hi-1) do |k|
    if (inputs[k] <= key)
      mi += 1
      new_value = inputs[k]
      inputs[k] = inputs[mi]  
      inputs[mi] = new_value
    end
	end
	inputs[hi] = inputs[mi+1]
	inputs[mi+1] = key
	mi+1
end

quick_sort [1, 10, 27, 7, 8, 10, 34, 100, 3, 4, 88, 10, 22, 64, 15], 0, 14