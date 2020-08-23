module Imdb
  class ClassicMovie < Movie
    def to_s
      "«#{title} — классический фильм, режиссёр #{director} " \
      "(ещё #{collection.filter(director: director).size} его фильмов в списке)»"
    end
  end
end
