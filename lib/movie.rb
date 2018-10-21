module Imdb
  class Movie
    require 'virtus'
    include Virtus.model
    require_relative 'ancient_movie'
    require_relative 'classic_movie'
    require_relative 'modern_movie'
    require_relative 'new_movie'

    class SplitArray < Virtus::Attribute
      def coerce(value)
        value.split(',')
      end
    end

    class ToInteger < Virtus::Attribute
      def coerce(value)
        value.to_i
      end
    end

    attribute :url, String
    attribute :title, String
    attribute :year, Integer
    attribute :country, String
    attribute :release, String
    attribute :genre, SplitArray
    attribute :duration, ToInteger
    attribute :rating, Float
    attribute :director, String
    attribute :actors, SplitArray
    attribute :collection, @collection

    GenreNotExist = Class.new(StandardError)
    ClassNotFound = Class.new(ArgumentError)

    attr_reader *%i[url title year country release genre duration rating director actors]

    def self.create(movie)
      case movie[:year].to_i
      when 1900..1944
        AncientMovie.new(movie)
      when 1945..1967
        ClassicMovie.new(movie)
      when 1968..1999
        ModernMovie.new(movie)
      when 2000..Time.now.year
        NewMovie.new(movie)
      end
    end

    def matches_filter?(options)
      options.reduce(true) do |res, (filter_name, filter_value)|
        if filter_name =~ /^exclude_(.+)/
          exclude_filter_name = Regexp.last_match(1)
          res && !matches_pattern?(exclude_filter_name, filter_value)
        else
          res && matches_pattern?(filter_name, filter_value)
        end
      end
    end

    def has_genre?(genre)
      raise GenreNotExist, "Genre #{genre} not exist" if @collection.genres.count(genre).zero?
      @genre.include?(genre)
    end

    def imdb_id
      url.split('/')[4]
    end

    def to_h
      {
        url: url,
        title: title,
        year: year,
        country: country,
        release: release,
        genre: genre,
        duration: duration,
        rating: rating,
        director: director,
        actors: actors
      }
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
  end
end
