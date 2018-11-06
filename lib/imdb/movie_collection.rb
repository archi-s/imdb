module Imdb
  # The MovieCollection class represents basic movie collection.
  # @param format [String] the format type, `file.csv`
  # @return [MovieCollection] object that contains all movies from the file.
  class MovieCollection
    require_relative 'cinemas/netflix'
    require_relative 'cinemas/theatre'

    include Enumerable

    KEYS = %i[url title year country release genre duration rating director actors].freeze

    ParametrNotExist = Class.new(StandardError)

    # Creates new instance and parses given csv file.
    # @param file [File] CSV file
    def initialize(file)
      @movies = CSV.read(file, col_sep: '|', headers: KEYS).map do |movie|
        Movie.create(movie.to_h.merge(collection: self))
      end
   end
    # Returns collection of movies.
    # @return [Array] All movies list.
    def all
      @movies
    end
    # This method allows to use Enumerable methods.
    def each
      @movies.each { |movie| yield movie }
    end
    # Collect genres from all movies in collection.
    # @return [Array] All genres list.
    def genres
      @movies.flat_map(&:genre).uniq
    end
    # Returns collection of movies sorted by options.
    # @param options [Symbol]
    # @return [Array] sorted movies list.
    def sort_by(options)
      check_options!(*options)
      @movies.sort_by(&options)
    end
    # Returns list of directors sorted by last name.
    # @return [Hash] list of directors.
    def directors
      @movies.map(&:director).uniq.sort_by { |director| director.split(' ').last }
    end
    # Number of films produced not in %production%.
    # @param production [String]
    # @return [Fixnum]
    # @example Get director stats.
    #   "collection.not_country_movies('USA')" #=> 84
    def not_country_movies(production)
      @movies.reject { |movie| movie.country.include? production }.count
    end
    # This method returns count release of movies sorted by month
    # @return [Array]
    # @example
    #   "collection.stat_by_month" #=> ["DECEMBER"=>10]
    def stat_by_month
      @movies.reject { |movie| movie.release.count('-').zero? }
      .map { |movie| Date.strptime(movie.release, '%Y-%m') }
      .sort_by(&:mon)
      .group_by { |release| release.strftime('%^B') }
      .map { |mon, amount| "#{mon} - #{amount.size}" }
    end
    # Lets you to filter collection by movie arguments.
    # Multiple filters are allowed.
    # @param options [Array<Hash>] List of filters.
    def filter(options)
      check_options!(*options.keys)
      all.select { |movie| movie.matches_filter?(options) }
    end
    # This method counts movies attribute values in collection by given attribute name.
    # @param options [Symbol]
    # @return [Hash]
    # @example Get director stats.
    #   "movie.stats(:director)" #=> "{"Frank Darabont"=>2, ...}"
    def stats(options)
      check_options!(*options)
      @movies.flat_map(&options).sort.group_by(&:itself).map { |k, v| [k, v.count] }.to_h
    end

    private
    # Checking options for compliance with specified keys
    # @param options [Hash]
    # @return [nil] or raise error
    def check_options!(*options)
      keys = all.sample.methods + [:exclude_country]
      options.map do |key|
        raise ParametrNotExist, "Parametr: #{key} not exist" unless keys.include? key
      end
    end
  end
end
