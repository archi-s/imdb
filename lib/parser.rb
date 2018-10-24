require 'dotenv'
Dotenv.load('../config/tmdb_api_key.env')
require 'progressbar'
require 'nokogiri'
require 'yaml'
require 'json'
require 'open-uri'

class Parser
  def initialize(collection)
    @api_key = ENV['TMDB_API_KEY']
    @collection = collection
  end

  def run
    progressbar = ProgressBar.create(total: @collection.all.length)
    @data = @collection.map do |movie|
      progressbar.increment
      { movie.imdb_id => { ru_title: tmdb_translation(movie.imdb_id), poster: tmdb_poster(movie.imdb_id), budget: budget_imdb(movie.imdb_id) } }
    end.reduce(&:merge).to_yaml
    self
  end

  def write(path)
    File.write(path, @data, mode: 'a')
  end

  private

  def tmdb_poster(imdb_id)
    link = "https://api.themoviedb.org/3/find/#{imdb_id}?api_key=#{@api_key}&external_source=imdb_id"
    poster_path = JSON.parse(open(link).read).dig("movie_results", 0, "poster_path")
    "https://image.tmdb.org/t/p/w185#{poster_path}"
  end

  def tmdb_translation(imdb_id)
    link = "https://api.themoviedb.org/3/movie/#{imdb_id}/translations?api_key=#{@api_key}"
    JSON.parse(open(link).read)["translations"].select { |hash| hash["english_name"] == "Russian" }.first["data"]["title"]
  end

  def budget_imdb(imdb_id)
    link = "https://www.imdb.com/title/#{imdb_id}/"
    budget = Nokogiri::HTML(open(link)).at('h4:contains("Budget:")')
    budget.nil? ? 'N/A' : budget.parent.text.gsub(/\D/, '')
  end
end