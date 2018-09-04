module Imdb
  class Netflix < MovieCollection
    extend CashBox

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

    def show(options, &blk)
      movie = select_movie(options, &blk)
      raise NotEnoughMoney, "Not enough $#{movie.cost - @balance}" if @balance < movie.cost
      @balance -= movie.cost
      puts "«Now showing: #{movie.title} #{Time.now.strftime('%H:%M:%S')} - #{(Time.now + movie.duration * 60).strftime('%H:%M:%S') }»"
    end

    def define_filter(filter_name, from: nil, arg: nil, &blk)
      @user_filters[filter_name] = from.nil? && arg.nil? ? blk : proc { |movie| @user_filters[from].call(movie, arg) }
    end

    private

    def select_movie(options)
      movies_by_options = options.reduce(all) do |movies, hash|
        if block_given?
          movies.select { |movie| yield(movie) }
        elsif @user_filters[hash.first].nil?
          raise MoviesByPatternNotFound, 'Movies by pattern not found' if filter(options).empty?
          filter(options)
        else
          hash.inject(movies) do |v|
            v.select { |movie| @user_filters[hash.first].call(movie, hash.last) }
          end
        end
      end
      movies_by_options.max_by { |movie| movie.rating + rand(100) }
    end
  end
end
