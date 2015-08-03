class Tree
  attr_accessor :root

  def initialize
    @root = nil
  end

  def insert(node)
    return nil if (node == nil || node.value == nil)
    if (root == nil)
      self.root = node
      return
    end
    tmp = root
    parent = nil
    while tmp != nil
      parent = tmp
      if (node.value < tmp.value)
        tmp = tmp.left
      else
        tmp = tmp.right
      end
    end
    node.parent = parent
    if node.value < parent.value
      parent.left = node
    else
      parent.right = node
    end
  end

  def inorder_walk
    walk root
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

    # if value < node.value
    #   search(value, node.left)
    # else
    #   search(value, node.right)
    # end
  end

  def minumun
    return root
    if root.left

    end
  end

  def maximun

  end

  def successor

  end

  def predecessor

  end

  def delete(value)

  end

  private

  def walk(node)
    if node != nil
      walk node.left
      p node.value
      walk node.right
    end
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
tree.insert node_5
tree.insert node_1
tree.insert node_4
tree.insert node_2
tree.insert node_3
tree.insert node_6
tree.insert node_7
tree.insert node_8
tree.insert node_9
tree.insert node_10
tree.insert node_11
tree.insert node_12
tree.insert node_13

# p tree
# p tree.root
# tree.inorder_walk
# p tree.root
p tree.search 255
# tree.walk node_4

