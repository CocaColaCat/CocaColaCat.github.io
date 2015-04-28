def insert_sort(inputs)

	length = inputs.length
	return inputs if length <= 0

	for i in 1..(length-1)
		current_index = i 
		key = inputs[current_index]
		previous = inputs[current_index-1]

		while (current_index > 0 && (key < previous)) 
			# place previous to the end
			inputs[current_index] = previous

			# place 1 step forward for the current key
			current_index -= 1
			inputs[current_index] = key

			# get the next previous
			previous = inputs[current_index-1]
		end
	end

	inputs
end