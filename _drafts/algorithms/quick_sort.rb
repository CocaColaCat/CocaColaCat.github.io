
def quicksort(inputs, p, r)
  q = partition inputs, p, r
  quicksort inputs, p, q
  quicksort inputs, q+1, r
end

def partition(inputs, p, r)
  key = inputs[r]
  low = p-1
  unsort = p
  p.downto(r-1) do |i|
    if inputs[i] <= key
      low += 1

      inputs[low], inputs[i] =inputs[i], inputs[low]
    end
    unsort += 1
  end
end
