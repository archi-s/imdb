class ByGenre
  def initialize(collection)
    collection.genres.each do |genre|
      define_singleton_method(genre.downcase) do
        collection.filter(genre: genre)
      end
    end
  end
end
