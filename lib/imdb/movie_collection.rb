module Imdb
  # The MovieCollection class represents basic movie collection that contains all movies
  # from the file.
  # It is necessary to access all the functions of working with movies.
  # @example Show all genres.
  #   collection.genres #=> ["Crime", "Drama", ...]
  class MovieCollection
    include Enumerable

    ParamsNotExist = Class.new(StandardError)

    # Creates new instance and parses given txt file.
    # @param file [txt] with all movies
    # @example Generate new collection.
    #   collection = Imdb::MovieCollection.new('../data/movies.txt') #=> #<Imdb::MovieCollection ID>
    def initialize(file)
      @movies = CSV.read(file, col_sep: '|')
                   .map { |movie| Imdb::Movie.create(Imdb::Movie::KEYS.zip(movie << self).to_h) }
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
      all.each { |m| yield m }
    end

    # This method returns count release of movies sorted by month
    # @return [Hash{String => Integer}]
    # @example Get stats: month - number of films made
    #   collection.stat_by_month #=> {"JANUARY" => 19, "FEBRUARY" => 24, ...}
    def stat_by_month
      @movies.reject { |m| m.release.count('-').zero? }
             .map { |m| Date.strptime(m.release, '%Y-%m') }
             .sort_by(&:mon)
             .group_by { |release| release.strftime('%B') }
             .map { |mon, amount| [mon, amount.size] }.to_h
    end

    # Get a collection of films sorted by any of the available criteria in the constant KEYS.
    # @param criterion [Symbol]
    # @return [Array<Movie>] sorted movies list.
    # @example Get the sort by year.
    #   collection.sort_by(:year) #=> [#<Imdb::ModernMovie Princess Mononoke 1997>, ...]
    def sort_by(field)
      check_params!(field)
      @movies.sort_by(&field)
    end

    # Lets you to filter collection by any movie criteria in the constant KEYS.
    # Multiple filters are allowed.
    # @param criteria [Hash] list of filters.
    # @return [Array<Movie>]
    # @example Get movie objects matching criteria
    # collection.filter(title: 'Persona', year: 1966, country: "Sweden") #=> \
    # [#<Imdb::ClassicMovie Persona 1966>, ...]
    def filter(params)
      check_params!(*params.keys)
      @movies.select { |m| m.matches?(params) }
    end

    # This method counts the number of films in the collection according to any criterion
    # available in the KEYS constant.
    # @param criterion [Symbol]
    # @return [Hash{String => Integer}]
    # @example Get directors stats.
    # collection.stats(:director) #=> {"Adam Elliot"=>1, "Akira Kurosawa"=>6, ...}
    def stats(field)
      check_params!(field)
      @movies.flat_map(&field).sort.group_by(&:itself).map { |k, v| [k, v.size] }.to_h
    end

    # Returns a list of genres from all the movies in the collection
    # and checks for the presence of the genre.
    # @return Boolean.
    # @example Checks for the presence of the genre.
    #   collection.genre_exist?('Comedy') #=> true
    def genre_exist?(genre)
      @movies.flat_map(&:genre).uniq.include? genre
    end

    private

    # Check of parameters of correspondence to the keys specified in the constant KEYS
    # @param criteria [Symbol]
    # @return [nil] or [ParametrNotExist]
    # @example Entering a non-existent criterion.
    # collection.stats(:director1) #=> Parametr: director1 not exist \
    # (Imdb::MovieCollection::ParametrNotExist)
    def check_params!(*field)
      res = field.reject do |v|
        v = Regexp.last_match(1) if v =~ /^exclude_(.+)/
        all.sample.respond_to?(v)
      end
      raise ParamsNotExist, "Params #{res.join(', ')} not exist" unless res.empty?
    end

    # Selects one movie from an array of films with a probably high rating
    # @param criteria [Array]
    # @return [nil] or [Array<Movie>]
    # @example Choose a movie.
    # collection.select_movie([Array<Movie>]) #=> <Movie>
    def select_movie(movies)
      movies.max_by { |movie| movie.rating + rand(100) }
    end

    def method_missing(field)
      if Imdb::Movie::KEYS.include? field
        Imdb::MethodChain.new(key: field, collection: self)
      else
        super
      end
    end

    def respond_to_missing?(field)
      Imdb::Movie::KEYS.include? field
    end
  end
end
