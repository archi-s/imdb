module Imdb
  class ClassicMovie < Movie
    private

    def to_s
      "«#{title} — классический фильм, режиссёр #{director} (ещё " \
      "#{@collection.filter(director: director).count} его фильмов в списке)»"
    end
  end
end
