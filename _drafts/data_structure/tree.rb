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

  def search(value)
  end

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

# p tree
# p tree.root
# tree.inorder_walk
tree.walk node_4

