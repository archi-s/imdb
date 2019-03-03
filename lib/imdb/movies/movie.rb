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

    GenreNotExist = Class.new(Error)
    ClassNotFound = Class.new(Error)

    KEYS = %i[url title year country release genre duration rating director actors].freeze

    attr_reader(*KEYS)

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
      else
        raise ClassNotFound, 'Class not found'
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

    def period
      self.class.to_s.gsub(/.*::(.*)Movie/, '\1').downcase.to_sym
    end

    COST = { ancient: 100, classic: 150, modern: 300, new: 500 }.freeze

    def cost
      Money.new(COST[period], 'USD')
    end

    def genre?(genre)
      raise GenreNotExist, "Genre #{genre} not exist" if @collection.genres.count(genre).zero?
      @genre.include?(genre)
    end

    def imdb_id
      url.split('/')[4]
    end

    def to_h
      KEYS.map { |var| [var, instance_variable_get("@#{var}")] }.to_h
    end

    private

    def matches_pattern?(filter_name, filter_value)
      result = send(filter_name)
      if result.is_a?(Array)
        if filter_value.is_a?(Array)
          filter_value.any? { |v| result.include?(v) }
        else
          result.include? filter_value
        end
      else
        filter_value === result # rubocop:disable Style/CaseEquality
      end
    end

    def to_s
      "#{movie.title} (#{movie.release}; #{movie.genre}) - #{movie.duration}"
    end

    def inspect
      "#<#{self.class} #{title} #{year}>"
    end
  end
end
