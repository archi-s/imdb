require 'progressbar'
require 'nokogiri'
require 'yaml'
require 'json'
require 'open-uri'

class Parser

  def initialize(collection)
    @api_key = YAML.load_file('../config/tmdb_api_key.yml')['tmdb_api_key']
    progressbar = ProgressBar.create(total: collection.all.length)
    data = collection.map do |movie|
      progressbar.increment
      { movie.imdb_id => { ru_title: get_translate_from_tmdb(movie.imdb_id), poster: get_poster_from_tmdb(movie.imdb_id), budget: get_budget_from_imdb(movie.imdb_id) } }
    end.reduce(&:merge)
    File.write('../views/data.yml', data.to_yaml)
  end

  def get_poster_from_tmdb(imdb_id)
    link = "https://api.themoviedb.org/3/find/#{imdb_id}?api_key=#{@api_key}&external_source=imdb_id"
    poster_path = JSON.parse(open(link).read)["movie_results"].first["poster_path"]
    "https://image.tmdb.org/t/p/w185#{poster_path}"
  end

  def get_translate_from_tmdb(imdb_id)
    link = "https://api.themoviedb.org/3/movie/#{imdb_id}/translations?api_key=#{@api_key}"
    JSON.parse(open(link).read)["translations"].select { |hash| hash["english_name"] == "Russian" }.first["data"]["title"]
  end

  def get_budget_from_imdb(imdb_id)
    link = "https://www.imdb.com/title/#{imdb_id}/"
    page = Nokogiri::HTML(open(link)).at('h4:contains("Budget:")')
    budget = page.nil? ? 'N/A' : page.parent.text.gsub(/\D/, '')
  end

end
