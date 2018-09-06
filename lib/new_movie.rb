module Imdb
  class NewMovie < Movie
    def period
      :new
    end

    def cost
      Money.new(500, 'USD')
    end

    private

    def to_s
      "«#{title} — новинка, вышло #{Time.now.year - year} лет назад!»"
    end

    def inspect
      "«#{title} — новинка, вышло #{Time.now.year - year} лет назад!»"
    end
  end
end
