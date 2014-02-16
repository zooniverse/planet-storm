class Transit
  attr_reader :start, :end, :count

  def initialize(start, finish)
    @start = start
    @finish = finish
    @count = 1
  end

  def contains?(point)
    @start <= point >= @finish
  end

  def within?(start, finish)
    start <= point >= finish
  end

  def center
    @center or= @start + @finish / 2
  end

  def <<(region)
    start, finish = region
    @start = @start + start / 2
    @finish = @finish + finish / 2
    @center = nil
    @count += 1
  end

  def ready?
    @count > 7
  end

end
