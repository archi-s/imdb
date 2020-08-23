require 'csv'
require 'date'
require 'dotenv'
require 'haml'
require 'json'
require 'money'
require 'nokogiri'
require 'open-uri'
require 'pathname'
require 'ruby-progressbar'
require 'slop'
require 'virtus'
require 'yaml'

module Imdb
  VERSION = '0.0.1'.freeze
  Error = Class.new(StandardError)

  IMDB_PATH = Pathname.new('./')

  MOVIE_FILE_PATH = IMDB_PATH.join('data/movies.txt')
  DATA_FILE_PATH = IMDB_PATH.join('data/data.yml')
  NETFLIX_HTML_PATH = IMDB_PATH.join('views/netflix.html')
  NETFLIX_HAML_PATH = IMDB_PATH.join('lib/imdb/template/netflix.haml')
  TMDB_API_KEY_PATH = IMDB_PATH.join('config/tmdb_api_key.env')
end

require_relative 'imdb/movie_collection'
require_relative 'imdb/movies/movie_construct'
require_relative 'imdb/movies/movie'
require_relative 'imdb/movies/ancient_movie'
require_relative 'imdb/movies/classic_movie'
require_relative 'imdb/movies/modern_movie'
require_relative 'imdb/movies/new_movie'
require_relative 'imdb/method_chain'
require_relative 'imdb/cash_box'
require_relative 'imdb/parser'
require_relative 'imdb/collection_renderer'
require_relative 'imdb/cinemas/netflix'
require_relative 'imdb/cinemas/theatre'
require_relative 'imdb/default_schedule'
require_relative 'imdb/period'
require_relative 'imdb/schedule'
