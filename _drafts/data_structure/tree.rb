class Tree
  attr_accessor :root, :count, :deep, :left_deep, :right_deep

  def initialize
    @root = nil
    @count = 0
    @deep = 0
    @left_deep = 0
    @right_deep = 0
  end

  def insert(node)
    return nil if (node == nil || node.value == nil)
    @count += 1
    if (root == nil)
      self.root = node
      @deep += 1
      @left_deep += 1
      @right_deep += 1
      return
    end
    tmp = root
    parent = nil
    add_to_left = false
    while tmp != nil
      parent = tmp
      if (node.value < tmp.value)
        tmp = tmp.left
        add_to_left = true
      else
        tmp = tmp.right
      end
    end
    node.parent = parent
    if node.value < parent.value
      parent.left = node
      if parent.right == nil
        add_to_left ? (@left_deep+=1) : (@right_deep+=1)
      end
    else
      parent.right = node
      if parent.left == nil
        add_to_left ? (@left_deep+=1) : (@right_deep+=1)
      end
    end
  end

  def tree_deep
    if @left_deep >= @right_deep
      return @deep if @left_deep == 0
      @left_deep
    else
      @right_deep
    end
  end

  def inorder_walk
    deep = 0
    walk root, deep
  end

  def print
    deep =
    left_walk root, deep
  end

  def search(value,start_from=nil)
    node = start_from || root
    return node if node.nil? || (value == node.value)
    next_node = node
    while next_node
      break if next_node.value == value
      if next_node.value < value
        next_node = next_node.right
      else next_node.value > value
        next_node = next_node.left
      end
    end
    next_node
  end

  def self.minumun(node)
    while node.left
      node = node.left
    end
    node
  end

  def maximun
    return nil if root.nil?
    node = root
    while node && node.right
      node = node.right
    end
    node
  end

  def successor
  end

  def predecessor
  end

  def delete(node)
    return nil if node.nil?
    p node.left.value
    p node.right.value
    if node.left == nil
      transplant(node, node.right)
    elsif node.right == nil
      transplant(node, node.left)
    else
      y = Tree.minumun(node.right)
      p y
      if y != node.right
        transplant(y, y.right)
        y.right = node.right
        node.right.parent = y
      end
      transplant(node, y)
      y.left = node.left
      y.left.parent = y
    end
  end

  private
  def walk(node, deep)
    if node != nil
      walk node.left, deep+1
      p "deep is #{deep}"
      p "#{node.value}"
      walk node.right, deep+1
    end
  end

  def left_walk(node,deep)
    if node != nil
      space = ""
      deep.times{ space += " " }
      p "#{space}#{node.value}"
      left_walk node.left, deep-1
      left_walk node.right, deep-1
    end
  end

  def transplant(u,v)
    if u == root
      root = v
    else
      if u == u.parent.left
        u.parent.left = v
      else
        u.parent.right = v
      end
    end
    v.parent = u.parent if v != nil
  end

end

class Node
  attr_accessor :value, :left, :right, :parent

  def initialize(value,left=nil,right=nil,parent=nil)
    @value, @left, @right, @parent = value, left, right, parent
  end

end

node_1 = Node.new(3)
node_2 = Node.new(6)
node_3 = Node.new(8)
node_4 = Node.new(30)
node_5 = Node.new(1)
node_6 = Node.new(30)
node_7 = Node.new(100)
node_8 = Node.new(-2)
node_9 = Node.new(-17)
node_10 = Node.new(-55)
node_11 = Node.new(11)
node_12 = Node.new(255)
node_13 = Node.new(-29)

tree = Tree.new
tree.insert node_1
tree.insert node_2
# tree.insert node_3
# tree.insert node_4
# tree.insert node_5
# tree.insert node_6
# tree.insert node_7
# tree.insert node_8
# tree.insert node_9
# tree.insert node_10
# tree.insert node_11
# tree.insert node_12
# tree.insert node_13

p tree.count
p tree.tree_deep

# p node_10.right
# p tree.root.left
# p tree
# tree.inorder_walk
# p node_2.value
# p Tree.minumun(node_9)
# p "before delete, tree is:"
# tree.inorder_walk
# tree.leftorder_walk
# tree.delete node_5
# p "delete #{node_5.value}"
# p "after delete, tree is:"
# p tree.inorder_walk
# p node_2.left
# p node_9.left
# p tree.maximun
# p tree.root
# p tree.search 255
# tree.walk node_4

# tree.delete node_13
# p tree.inorder_walk

