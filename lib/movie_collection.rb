module Imdb
  class MovieCollection
    require_relative 'netflix'
    require_relative 'theatre'

    include Enumerable

    KEYS = %i[url title year country release genre duration rating director actors].freeze

    ParametrNotExist = Class.new(StandardError)

    def initialize(file)
      @movies = CSV.read(file, col_sep: '|', headers: KEYS).map do |movie|
        Movie.create(movie.to_h.merge(collection: self))
      end
   end

    def all
      @movies
    end

    def each
      @movies.each { |movie| yield movie }
    end

    def genres
      @movies.flat_map(&:genre).uniq
    end

    def sort_by(options)
      check_options!(*options)
      @movies.sort_by(&options)
    end

    def top_five_movies_by_duration
      @movies.sort_by(&:duration).last(5).reverse
    end

    def ten_comedies
      @movies.select { |movie| movie.genre.include? 'Comedy' }.sort_by(&:release).first(10)
    end

    def directors
      @movies.map(&:director).uniq.sort_by { |director| director.split(' ').last }
    end

    def not_country_movies(production)
      @movies.reject { |movie| movie.country.include? production }.count
    end

    def stat_by_month
      @movies.reject { |movie| movie.release.count('-').zero? }
      .map { |movie| Date.strptime(movie.release, '%Y-%m') }
      .sort_by(&:mon)
      .group_by { |release| release.strftime('%^B') }
      .map { |mon, amount| "#{mon} - #{amount.size}" }
    end

    def filter(options)
      #check_options!(*options.keys)
      all.select { |movie| movie.matches_filter?(options) }
    end

    def stats(options)
      check_options!(*options)
      @movies.flat_map(&options).sort.group_by(&:itself).map { |k, v| [k, v.count] }.to_h
    end

    private

    def check_options!(*options)
      options.map do |variable|
        raise ParametrNotExist, "Parametr: #{variable} not exist" unless all.sample.methods.include? variable
      end
    end
  end
end
