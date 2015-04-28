def bubble_sort(inputs)
	return inputs if inputs.size < 2
	(inputs.size-2).downto(0) do |i|
	  (0..i).each do |j|
	  	inputs[j], inputs[j+1] =inputs[j+1], inputs[j] if inputs[j] > inputs[j+1]
	  end
	end
	p inputs
end