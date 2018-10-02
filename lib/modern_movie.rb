module Imdb
  class ModernMovie < Movie
    def period
      :modern
    end

    def cost
      Money.new(300, 'USD')
    end

    private

    def to_s
      "«#{title} — современное кино: играют #{actors.join(', ')}»"
    end

    def inspect
      to_s
    end
  end
end
