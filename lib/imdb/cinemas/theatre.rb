module Imdb
  class Theatre < MovieCollection
    include CashBox

    Closed = Class.new(Error)
    MovieNotShowing = Class.new(Error)

    attr_reader :schedule

    def initialize(file, &blk)
      super
      @schedule = block_given? ? Schedule.new(&blk) : Schedule.new(&Schedule.default)
    end

    def show(time)
      period = @schedule.periods.detect { |period| period.time === time }
      raise Closed, "At #{time} o’clock the cinema is closed" if period.nil?
      movie = select_movie(filter(period.pattern))
      start_time = Time.now.strftime '%H:%M:%S'
      end_time = (Time.now + (movie.duration * 60)).strftime '%H:%M:%S'
      puts "«Now showing: #{movie.title} #{start_time} - #{end_time}»"
    end

    def when?(title)
      res = @schedule.periods.reject { |period| (filter(period.pattern) & filter(title: title)).empty? }
      res.empty? ? raise(MovieNotShowing, "Movie #{title} not showing") : res.map(&:time)
    end

    def buy_ticket
      time_now = Time.now.strftime '%H:%M'
      period = @schedule.periods.detect { |period| period.time === time_now }
      raise Closed, "At #{time_now} o’clock the cinema is closed" if period.nil?
      cashbox(period.price)
      show(time_now)
    end
  end
end
