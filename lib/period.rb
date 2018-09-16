class Period

  class ::Range
    def overlaps?(time)
      last > time.first
    end
  end

  POSSIBLE_NAMES = %i[url title year country release genre duration rating director actors].freeze

  attr_reader :time, :filter, :halls, :description, :cost

  def initialize(time, &blk)
    @time = time
    instance_eval(&blk)
  end

  def description(v = nil)
    return @description if v.nil?
    @description = v
  end

  def filters(**attr_hash)
    @filter = attr_hash
  end

  def price(price)
    @cost = price
  end

  def hall(*hall)
    @halls = hall
  end

  def covers?(p2)
    time.overlaps?(p2.time) && (halls & p2.halls).any?
  end

  def method_missing(meth, arg)
    if POSSIBLE_NAMES.include?(meth)
      filters(meth => arg)
    else
      super
    end
  end

end
