
class MyStack

  def initialize
    @stack = []
  end

  def empty?
    @stack.empty?
  end

  def push(x)
    @stack << x
  end

  def top
    @stack.last
  end

  def pop
    if empty?
      raise Exception
    else
      @stack.pop
    end
  end

  def print
    puts @stack.join(',')
  end

end

s = MyStack.new
s.print
s.push(10)
s.print
s.push(2)
s.print
s.pop
s.print
s.push(19)
s.push(49)
s.print
s.pop
s.print

