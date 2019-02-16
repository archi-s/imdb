module Imdb
  class AncientMovie < Movie
    private

    def to_s
      "«#{title} — старый фильм (#{year} год)»"
    end
  end
end
