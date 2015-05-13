class Node
  attr_accessor :next, :node, :prev

  def initialize(node)
    @node = node
  end

end

class NodeList
  attr_accessor :head, :count

  def initialize
    @count = 0
  end

  def insert(node)
    if head.nil?
      @head = node
    else
      @head.prev = node
      node.next = @head
      @head = node
      @head.prev = nil
    end
    @count += 1
  end

  def delete(node)
    return if node.nil?
    return if node.prev.nil? &&  node.node != head.node

    if node.prev.nil?
      @head = node.next
    else
      node.prev.next = node.next
    end
    if node.next != nil
      node.next.prev = node.prev
    end
    @count -= 1
  end

  def search(k)
    x = head
    while x != nil && x.node != k
      x = x.next
    end
    x
  end

  def empty?
    head.nil?
  end

  def to_list
    msg ||= ""
    node = head
    while node != nil
      msg << "#{node.node} -> "
      node = node.next
    end
    msg[0..-5]
  end

end

nl = NodeList.new
p nl.empty?

node = Node.new("Hello")
node_2 = Node.new("Yo")

nl.insert node
nl.insert node_2
nl.insert Node.new("Hi")

p nl.to_list

p nl.count

nl.delete node
nl.delete node_2

p nl.search "Hi"

p nl.to_list
p nl.count
p nl.empty?

