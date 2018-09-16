module Imdb
  class Netflix < MovieCollection
    extend CashBox
    require_relative 'by_genre'
    require_relative 'by_country'

    NotEnoughMoney               = Class.new(StandardError)
    MoviesByPatternNotFound = Class.new(StandardError)
    NegativeAmountEntered    = Class.new(StandardError)
    MovieByTitleNotFound        = Class.new(StandardError)

    attr_reader :balance, :user_filters

    def initialize(file)
      super
      @balance = Money.new(0, 'USD')
      @user_filters = {}
    end

    def how_much?(title)
      raise MovieByTitleNotFound, "Movie #{title} not found" if filter(title: /#{title}/i).empty?
      filter(title: /#{title}/i).map(&:cost).map(&:format)
    end

    def pay(money)
      raise NegativeAmountEntered, "The amount #{money} can not be entered" if money <= 0
      self.class.pay(money * 100)
      @balance += Money.new(money * 100, 'USD')
    end

    def show(**options, &blk)
      movie = select_movie(**options, &blk)
      raise NotEnoughMoney, "Not enough $#{movie.cost - @balance}" if @balance < movie.cost
      @balance -= movie.cost
      puts "«Now showing: #{movie.title} (#{movie.year}; #{movie.genre.join(', ')}; #{movie.country}) #{Time.now.strftime('%H:%M:%S')} - #{(Time.now + movie.duration * 60).strftime('%H:%M:%S') }»"
    end

    def define_filter(filter_name, from: nil, arg: nil, &blk)
      @user_filters[filter_name] = from.nil? && arg.nil? ? blk : proc { |movie| @user_filters[from].call(movie, arg) }
    end

    def by_genre
      ByGenre.new(self)
    end

    def by_country
      ByCountry.new(self)
    end

    # class ByCountry
    #   def initialize(collection)
    #     collection.map(&:country).uniq.each do |country|
    #       define_singleton_method(country.downcase) do
    #         collection.filter(country: country)
    #       end
    #     end
    #   end
    # end

    private

     def select_movie(**options)
      showing_movie = options.reduce(all) do |movies, (field, value)|
        if block_given?
          movies.select { |movie| yield(movie) }
        elsif @user_filters[field].nil?
          raise MoviesByPatternNotFound, 'Movies by pattern not found' if filter({field => value}).empty?
          movies.select { |movie| filter({field => value}).include? movie }
        else
          movies.select { |movie| @user_filters[field].call(movie, value) }
        end
       end
      showing_movie.max_by { |movie| movie.rating + rand(100) }
    end
  end
end
