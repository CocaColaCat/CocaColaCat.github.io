
def merge_sort(inputs, start_index, end_index)
	if start_index < end_index
		split_index = (start_index + end_index)/2
		merge_sort inputs, start_index, split_index
		merge_sort inputs, (split_index+1), end_index
		merge inputs, start_index, split_index, end_index
	end
end

def merge(inputs, start_index, split_index, end_index)
	left = inputs[start_index..split_index]
	right = inputs[(split_index+1)..end_index]
	left << Float::INFINITY
	right << Float::INFINITY

	l = 0
	r = 0
	for i in start_index..end_index
		if left[l] < right[r]
			inputs[i] = left[l]
			l += 1
		else
			inputs[i] = right[r]
			r += 1
		end
	end
end