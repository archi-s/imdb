class ByCountry
  def initialize(collection)
    @collection = collection
  end

  def method_missing(country)
    movies = @collection.filter(country: /#{country.to_s.tr('_', ' ')}/i)
    movies.empty? ? super : movies
  end
end
