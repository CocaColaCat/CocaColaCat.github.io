# index must >= 1
def max_heapify(inputs, index)
  l = index*2 - 1
  r = index*2
  index -= 1

  if (l < inputs.size) && (inputs[index] <= inputs[l])
    largest = l
  else
    largest = index
  end
  if (r < inputs.size) && (inputs[largest] <= inputs[r])
    largest = r
  end

  if largest != index
    inputs[index], inputs[largest] = inputs[largest], inputs[index]
    max_heapify(inputs, largest)
  end
end

def build_max_heap(inputs)
  return inputs if inputs.size == 1
  size = inputs.size
  (size/2).downto(1) do |i|
    max_heapify(inputs, i)
  end
end

def heapsort(inputs)
  p "the original inputs is #{inputs}"
  build_max_heap(inputs)
  p "after heapify is #{inputs}"
  result = []
  (inputs.size-1).downto(0) do |i|
    result[i] = inputs[0]
    inputs[0] = inputs.pop
    max_heapify(inputs, 1)
  end
  p "result is #{result}"
end

heapsort [1, 8, 10, 5, 10, 22, 100, 4, 29, 6, 102]
