module Imdb
  class Theatre < MovieCollection
    require_relative 'period_builder'
    require_relative 'default_schedule'
    include CashBox

    PeriodNotFound    = Class.new(StandardError)
    MovieNotShowing = Class.new(StandardError)
    ScheduleError       = Class.new(StandardError)
    HallError               = Class.new(StandardError)
    PeriodError           = Class.new(StandardError)

    def initialize(file, &blk)
      super(file)
      @halls = {}
      @periods = []
      block_given? ? instance_eval(&blk) : instance_eval(&DefaultSchedule.schedule)
      check_periods
      check_schedule
    end

    def when?(title)
      movie = filter(title: title).sample
      times = @periods.find_all do |period|
                        filter(period.filters).include? movie
                      end.map(&:time)
      times.empty? ? raise(MovieNotShowing, "Movie: #{title} not showing") : times.map { |time| "From #{time.first} to #{time.last}" }
    end

    def buy_ticket
      time_now = Time.now.strftime "%H:%M"
      cost = @periods.select { |period| period.time.cover? time_now }.map(&:price).first
      pay(cost)
      show(time_now)
    end

    def show(time)
      filter = @periods.select { |period| period.time.cover? time }.map { |period| period.filters }.first
      raise PeriodNotFound, "Period #{time} not found" if filter.nil?
      showing_movie = filter(filter).max_by { |movie| movie.rating + rand(100) }
      puts "«Now showing: #{showing_movie.title} (#{showing_movie.year}; #{showing_movie.genre.join(', ')}; #{showing_movie.country}) #{Time.now.strftime '%H:%M:%S'} - #{(Time.now + (showing_movie.duration * 60)).strftime '%H:%M:%S' }»"
    end

    private

    def hall(color, attr_hash)
      check_hall(color, attr_hash)
      @halls[color] = attr_hash
    end

    def period(time, &block)
      @periods << PeriodBuilder.new(time, &block).period
    end

    def check_hall(color, attr_hash)
      raise HallError, "Invalid hall color" unless color.is_a? Symbol
      raise HallError, "Invalid hall title" unless attr_hash[:title].is_a? String
      raise HallError, "Invalid hall places" if !attr_hash[:places].is_a?(Fixnum) || attr_hash[:places] < 0
      raise HallError, "Incorrect number of parameters" if attr_hash.count > 2
    end

    def check_periods
      @periods.map do |period|
        raise PeriodError, "Invalid time #{period.time}" unless period.time.is_a? Range
        raise PeriodError, "Invalid description #{period.description}" unless period.description.is_a? String
        raise PeriodError, "Invalid filters #{period.filters}" if filter(period.filters).empty?
        raise PeriodError, "Invalid price #{period.price}" if !period.price.is_a?(Fixnum) || period.price < 0
        raise PeriodError, "Invalid hall #{period.hall}" if period.hall.any? { |hall| @halls[hall].nil? }
      end
    end

    def check_schedule
      @periods
          .combination(2)
          .select { |p1, p2| p1.covers?(p2) }
          .map do |period1, period2|
            hall_title = @halls[(period1.hall & period2.hall).first][:title]
            raise ScheduleError, "Сеансы: '#{period1.description}' и '#{period2.description}' пересекаются в зале: '#{hall_title}' в период с #{period2.time.first} по #{period1.time.last}"
          end
    end
  end
end
