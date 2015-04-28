
def find_max_crossing_subarray(inputs, low, mid, high)
  max_left_index = 0
  left_sum = -Float::INFINITY
  sum = 0

  mid.downto(low) do |i|
    sum += inputs[i]
    max_left_index, left_sum = i, sum if ( sum > left_sum )
  end

  max_right_index = 0
  right_sum = -Float::INFINITY
  sum = 0

  (mid + 1).upto(high) do |j|
    sum += inputs[j]
    max_right_index, right_sum = j, sum if ( sum > right_sum )
  end

  return max_left_index, max_right_index, (left_sum + right_sum)
end

def find_max_subarray(inputs, low, high)
	return low, high, inputs[low] if  (high == low)

	mid = (low + high) / 2
  indent = ""
  mid.times { |i| indent += "-" }
  puts "#{indent} mid is #{mid}"

  left_low, left_high, left_max = find_max_subarray(inputs, low, mid)
  right_low, right_high, right_max = find_max_subarray(inputs, (mid+1), high)
  cross_low, cross_high, cross_max = find_max_crossing_subarray(inputs, low, mid, high)
  
  if (left_max >= cross_max) && (left_max >= right_high)
    return left_low, left_high, left_max
  elsif (right_max >= left_max) && (right_max >= cross_high)
    return right_low, right_high, right_max
  else
  	return cross_low, cross_high, cross_max
  end
  		
end


inputs = [19, -10, 20, 1, 100, 45, 100, -32, -34, 200, 45, 3, 77, 18, -12, -7]

puts find_max_subarray(inputs, 0, 15)