def max_heapify(inputs, index)
  p inputs
  l = index*2 - 1
  r = index*2
  index -= 1

  if (inputs[index] <= inputs[l]) && (l <= inputs.size)
    largest = l
  else
    largest = index
  end
  if (inputs[largest] <= inputs[r]) && (r <= inputs.size)
    largest = r
  end

  if largest != index
    inputs[index], inputs[largest] = inputs[largest], inputs[index]
    p inputs
    p largest
    max_heapify(inputs, largest)
  end

end

max_heapify [27, 17, 3, 16, 13, 10, 1, 5, 7, 12, 4, 8, 9, 0], 3
