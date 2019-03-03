module Imdb
  # The MovieCollection class represents basic movie collection that contains all movies
  # from the file.
  # It is necessary to access all the functions of working with movies.
  # @example Show all genres.
  #   collection.genres #=> ["Crime", "Drama", ...]
  class MovieCollection
    require_relative 'cinemas/netflix'
    require_relative 'cinemas/theatre'

    include Enumerable

    KEYS = %i[url title year country release genre duration rating director actors].freeze
    ParametrNotExist = Class.new(Error)
    FileNotFound = Class.new(Error)

    # Creates new instance and parses given txt file.
    # @param file [txt] with all movies
    # @example Generate new collection.
    #   collection = Imdb::MovieCollection.new('../data/movies.txt') #=> #<Imdb::MovieCollection ID>
    def initialize(file)
      raise FileNotFound, "#{file} not found" unless File.exist?(file)
      @movies = CSV.read(file, col_sep: '|', headers: KEYS).map do |movie|
        Movie.create(movie.to_h.merge(collection: self))
      end
    end

    # Returns an array with all the films in the collection, in the order in which they are read
    # from the file.
    # @return [Array<Movie>] of child classes: NewMovie, AncientMovie, ModernMovie, ClassicMovie.
    # @example Get an array of all movie objects from the MovieCollection object.
    #   collection.all #=> [#<Imdb::ModernMovie Princess Mononoke 1997>, ...]
    def all
      @movies
    end

    # This method allows to use Enumerable methods.
    def each
      @movies.each { |movie| yield movie }
    end

    # Returns a list of genres from all films in the collection.
    # @return [Array<String>] of genres.
    # @example Get all genres.
    #   collection.genres #=> ["Comedy", "Drama", ...]
    def genres
      @movies.flat_map(&:genre).uniq
    end

    # Get a collection of films sorted by any of the available criteria in the constant KEYS.
    # @param criterion [Symbol]
    # @return [Array<Movie>] sorted movies list.
    # @example Get the sort by year.
    #   collection.sort_by(:year) #=> [#<Imdb::ModernMovie Princess Mononoke 1997>, ...]
    def sort_by(criterion)
      check_options!(*criterion)
      @movies.sort_by(&criterion)
    end

    # Returns list of directors sorted by last name.
    # @return [Array<String>] of directors.
    # @example Get sorted directors.
    #   collection.directors #=> ["Woody Allen", "Roger Allers", ...]
    def directors
      @movies.map(&:director).uniq.sort_by { |director| director.split(' ').last }
    end

    # Number of films produced not in %country%.
    # @param country [String]
    # @return [Fixnum]
    # @example Get the number of movies.
    #   collection.not_country_movies('USA') #=> 84
    def not_country_movies(country)
      @movies.reject { |movie| movie.country.include? country }.count
    end

    # This method returns count release of movies sorted by month
    # @return [Hash{String => Integer}]
    # @example Get stats: month - number of films made
    #   collection.stat_by_month #=> {"JANUARY" => 19, "FEBRUARY" => 24, ...}
    def stat_by_month
      @movies.reject { |movie| movie.release.count('-').zero? }
             .map { |movie| Date.strptime(movie.release, '%Y-%m') }
             .sort_by(&:mon)
             .group_by { |release| release.strftime('%^B') }
             .map { |mon, amount| { mon => amount.size } }.reduce(&:merge)
    end

    # Lets you to filter collection by any movie criteria in the constant KEYS.
    # Multiple filters are allowed.
    # @param criteria [Hash] list of filters.
    # @return [Array<Movie>]
    # @example Get movie objects matching criteria
    # collection.filter(title: 'Persona', year: 1966, country: "Sweden") #=> \
    # [#<Imdb::ClassicMovie Persona 1966>, ...]
    def filter(criteria)
      check_options!(*criteria.keys)
      all.select { |movie| movie.matches_filter?(criteria) }
    end

    # This method counts the number of films in the collection according to any criterion
    # available in the KEYS constant.
    # @param criterion [Symbol]
    # @return [Hash{String => Integer}]
    # @example Get directors stats.
    # collection.stats(:director) #=> {"Adam Elliot"=>1, "Akira Kurosawa"=>6, ...}
    def stats(criterion)
      check_options!(*criterion)
      @movies.flat_map(&criterion).sort.group_by(&:itself).map { |k, v| [k, v.count] }.to_h
    end

    private

    # Check of parameters of correspondence to the keys specified in the constant KEYS
    # @param criteria [Symbol]
    # @return [nil] or [ParametrNotExist]
    # @example Entering a non-existent criterion.
    # collection.stats(:director1) #=> Parametr: director1 not exist \
    # (Imdb::MovieCollection::ParametrNotExist)
    def check_options!(*criteria)
      keys = all.sample.methods + [:exclude_country]
      criteria.map do |key|
        raise ParametrNotExist, "Parametr: #{key} not exist" unless keys.include? key
      end
    end

    def inspect
      "#<#{self.class} ID:#{object_id}>"
    end
  end
end
