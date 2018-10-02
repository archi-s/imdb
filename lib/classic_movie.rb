module Imdb
  class ClassicMovie < Movie
    def period
      :classic
    end

    def cost
      Money.new(150, 'USD')
    end

    private

    def to_s
      "«#{title} — классический фильм, режиссёр #{director} (ещё #{@collection.filter(director: director).count} его фильмов в списке)»"
    end

    def inspect
      to_s
    end
  end
end
