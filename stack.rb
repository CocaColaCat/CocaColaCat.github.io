
class MyStack

  def initialize
    @stack = []
  end

  def empty?
    @stack.empty?
  end

  # def push(x)
  #   @stack << x
  # end

  def top
    @stack.last
  end

  def pop
    if empty?
      raise Exception
    else
      @stack.last
    end
  end

  def print
    puts @stack.class
  end

end

s = MyStack.new
s.print
# s.push(10)
# s.print
# s.push(2)
# s.print
# s.pop
# s.print

