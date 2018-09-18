module Imdb
  class Theatre < MovieCollection
    require_relative 'period'
    require_relative 'default_schedule'
    include CashBox

    attr_reader :hall

    PeriodNotFound    = Class.new(StandardError)
    MovieNotShowing = Class.new(StandardError)
    PeriodsError          = Class.new(StandardError)

    def initialize(file, &blk)
      super(file)
      @hall = {}
      @periods = []
      block_given? ? instance_eval(&blk) : instance_eval(&DefaultSchedule.schedule)
      check_schedule
    end

    def hall(color, **attr_hash)
      @hall[color] = attr_hash
    end

    def period(time, &blk)
      @periods << Period.new(time, &blk)
    end

    def check_schedule
      @periods
          .combination(2)
          .select { |p1, p2| p1.covers?(p2) }
          .map do |period1, period2|
            hall_title = @hall[(period1.halls & period2.halls).first][:title]
            raise PeriodsError, "Сеансы: '#{period1.specification}' и '#{period2.specification}' пересекаются в зале: '#{hall_title}' в период с #{period2.time.first} по #{period1.time.last}"
          end
    end

    def when?(title)
      movie = filter(title: title).sample
      times = @periods.find_all do |period|
                        filter(period.filter).include? movie
                      end.map(&:time)
      times.empty? ? raise(MovieNotShowing, "Movie: #{title} not showing") : times.map { |time| "From #{time.first} to #{time.last}" }
    end

    def buy_ticket
      time_now = Time.now.strftime "%H:%M"
      cost = @periods.select { |period| period.time.cover? time_now }.map(&:cost).first
      pay(cost)
      show(time_now)
    end

    def show(time)
      filter = @periods.select { |period| period.time.cover? time }.map { |period| period.filter }.first
      raise PeriodNotFound, "Period #{time} not found" if filter.nil?
      showing_movie = filter(filter).max_by { |movie| movie.rating + rand(100) }
      puts "«Now showing: #{showing_movie.title} (#{showing_movie.year}; #{showing_movie.genre.join(', ')}; #{showing_movie.country}) #{Time.now.strftime '%H:%M:%S'} - #{(Time.now + (showing_movie.duration * 60)).strftime '%H:%M:%S' }»"
    end
  end
end
