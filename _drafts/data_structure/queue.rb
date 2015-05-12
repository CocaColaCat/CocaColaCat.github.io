
class MyQueue

  def initialize
    @queue = []
  end

  def empty?
    @queue.empty?
  end

  def enqueue(x)
    @queue << x
  end

  def head
    @queue.first
  end

  def tail
    @queue.last
  end

  def dequeue
    if empty?
      raise Exception
    else
      @queue.slice!(0)
    end
  end

  def print
    puts @queue.join(',')
  end

end

q = MyQueue.new
q.print
q.enqueue(10)
q.print
q.enqueue(2)
q.print
q.dequeue
q.print
q.enqueue(19)
q.enqueue(49)
q.print
q.dequeue
q.print

