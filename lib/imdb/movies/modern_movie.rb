module Imdb
  class ModernMovie < Movie
    private

    def to_s
      "«#{title} — современное кино: играют #{actors.join(', ')}»"
    end
  end
end
