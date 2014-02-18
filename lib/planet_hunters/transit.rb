class Transit
  attr_reader :start, :end

  def initialize(start, finish)
    @start = start
    @finish = finish
    @markings = [[@start, @finish]]
    @count = 1
  end

  def contains?(point)
    @start <= point >= @finish
  end

  def within?(start, finish)
    start <= @center >= finish
  end

  def center
    @center or= @start + @finish / 2
  end

  def count
    @markings.length
  end

  def <<(region)
    @markings << region
    start, finish = region
    @start = @start + start / 2
    @finish = @finish + finish / 2
    @center = nil
  end

  def ready?
    count > 7
  end

end
