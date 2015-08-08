class Node
	attr_accessor :value, :left, :right
	
	def initialize(value, left=nil, right=nil)
		@value, @left, @right = value, left, right
	end

end

class Tree
	
	def initialize; end

	def insert(node)
		
	end

	def root
		
	end

	def sort
		
	end

	def max
		
	end

	def min
		
	end

	def delete(node)
		
	end

	def search(key)
		
	end

end

node_1 = Node.new(1)
node_2 = Node.new(2)
node_3 = Node.new(20)
node_4 = Node.new(12)
node_5 = Node.new(29)
node_6 = Node.new(-29)

tree = Tree.new
tree.insert node_1
tree.insert node_2
tree.insert node_3
tree.insert node_4
tree.insert node_5