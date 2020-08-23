module Imdb
  class Netflix < MovieCollection
    extend CashBox

    NotEnoughMoney = Class.new(Error)
    CannotNegative = Class.new(Error)
    MovieNotFound = Class.new(Error)

    COST = { ancient: 100, classic: 150, modern: 300, new: 500 }.freeze
    USER_FILTERS = {}

    attr_reader :balance

    def initialize(file)
      super
      @balance = Money.new(0, 'USD')
    end

    def how_much?(title)
      (movie = select_movie(filter(title: title))) || raise(MovieNotFound, "Movie #{title} not found")
      Money.new(COST[movie.period], 'USD')
    end

    def account(money)
      raise CannotNegative, "Cannot be negative #{money}" if money <= 0
      self.class.cashbox(money)
      @balance += Money.new(money, 'USD')
    end

    def show(params = nil, &blk)
      (movie = select_movie(showing_movies(params, &blk))) || raise(MovieNotFound)
      paid(movie)
      start_time = Time.now.strftime '%H:%M:%S'
      end_time = (Time.now + (movie.duration * 60)).strftime '%H:%M:%S'
      puts "«Now showing: #{movie.title} (#{movie.year}; #{movie.genre.join(', ')}; " \
      "#{movie.country}) #{start_time} - #{end_time}»"
    end

    def define_filter(filter_name, from: nil, arg: nil, &blk)
      USER_FILTERS[filter_name] = from.nil? && arg.nil? ? blk : proc { |movie| USER_FILTERS[from].call(movie, arg) }
    end

    def save_to_html
      Imdb::CollectionRenderer.new(self).write(Imdb::NETFLIX_HTML_PATH)
    end

    private

    def showing_movies(params = nil)
      if params.nil?
        all.select { |movie| yield(movie) } if block_given?
      else
        res = params.reduce(all) do |movies, (field, value)|
          if USER_FILTERS[field].nil?
            movies.select { |movie| filter(field => value).include? movie }
          else
            movies.select { |movie| USER_FILTERS[field].call(movie, value) }
          end
        end
        block_given? ? res.select { |movie| yield(movie) } : res
      end
    end

    def paid(movie)
      cost = how_much?(movie.title)
      @balance >= cost ? @balance -= cost : raise(NotEnoughMoney, "Not enough: #{cost - @balance}")
    end
  end
end
