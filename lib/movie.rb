module Imdb
  class Movie
    require_relative 'ancient_movie'
    require_relative 'classic_movie'
    require_relative 'modern_movie'
    require_relative 'new_movie'

    GenreNotExist = Class.new(StandardError)
    ClassNotFound = Class.new(ArgumentError)

    attr_reader *%i[url title year country release genre duration rating director actors]

    def initialize(movie, collection)
      @url, @title, @year, @country, @release, @genre, @duration, @rating, @director, @actors = movie.map(&:itself)
      @year, @duration, @rating, @genre, @actors = @year.to_i, @duration.to_i, @rating.to_f, @genre.split(','), @actors.split(',')
      @collection = collection
    end

    def self.create(movie, collection)
      case movie[2].to_i
      when 1900..1944
        AncientMovie.new(movie, collection)
      when 1945..1967
        ClassicMovie.new(movie, collection)
      when 1968..1999
        ModernMovie.new(movie, collection)
      when 2000..Time.now.year
        NewMovie.new(movie, collection)
      end
    end

    def matches_filter?(options)
      options.reduce(true) do |res, (filter_name, filter_value)|
        res && matches_pattern?(filter_name, filter_value)
      end
    end

    def has_genre?(genre)
      raise GenreNotExist, "Genre #{genre} not exist" if @collection.genres.count(genre).zero?
      @genre.include?(genre)
    end

    private

    def matches_pattern?(filter_name, filter_value)
      result = self.send(filter_name)
      if result.is_a?(Array)
        if filter_value.is_a?(Array)
          filter_value.any? { |v| result.include?(v) }
        else
          result.include? filter_value
        end
      else
        filter_value === result
      end
    end

    def to_s
      "#{movie.title} (#{movie.release}; #{movie.genre}) - #{movie.duration}"
    end

    def inspect
      "#{movie.title} (#{movie.release}; #{movie.genre}) - #{movie.duration}"
    end
  end
end
