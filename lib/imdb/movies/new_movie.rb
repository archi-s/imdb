module Imdb
  class NewMovie < Movie
    def to_s
      "«#{title} — новинка, вышло #{Time.now.year - year} лет назад!»"
    end
  end
end
