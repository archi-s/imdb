module Imdb
  class AncientMovie < Movie
    def period
      :ancient
    end

    def cost
      Money.new(100, 'USD')
    end

    private

    def to_s
      "«#{title} — старый фильм (#{year} год)»"
    end

    # def inspect
    #   to_s
    # end
  end
end
