module Imdb
  class AncientMovie < Movie
    def to_s
      "«#{title} — старый фильм (#{year} год)»"
    end
  end
end
