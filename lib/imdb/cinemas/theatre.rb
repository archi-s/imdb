module Imdb
  class Theatre < MovieCollection
    require_relative '../period_builder'
    require_relative '../default_schedule'
    include CashBox

    PeriodNotFound = Class.new(Error)
    MovieNotShowing = Class.new(Error)
    ScheduleError = Class.new(Error)
    HallError = Class.new(Error)
    PeriodError = Class.new(Error)

    def initialize(file, &blk)
      super(file)
      @halls = {}
      @periods = []
      block_given? ? instance_eval(&blk) : instance_eval(&DefaultSchedule.schedule)
      check_schedule
      check_periods
    end

    def when?(title)
      movie = filter(title: title).sample
      times = @periods.find_all { |period| filter(period.filters).include? movie }.map(&:time)
      raise MovieNotShowing, "Movie: #{title} not showing" if times.empty?
      times.map { |time| "From #{time.first} to #{time.last}" }
    end

    def buy_ticket
      time_now = Time.now.strftime '%H:%M'
      cost = @periods.select { |period| period.time.cover? time_now }.map(&:price).first
      pay(cost)
      show(time_now)
    end

    def show(time)
      filter = @periods.select { |period| period.time.cover? time }.map(&:filters).first
      raise PeriodNotFound, "Period #{time} not found" if filter.nil?
      showing_movie = filter(filter).max_by { |movie| movie.rating + rand(100) }
      puts "«Now showing: #{showing_movie.title} (#{showing_movie.year}; " \
      "#{showing_movie.genre.join(', ')}; #{showing_movie.country}) " \
      "#{Time.now.strftime '%H:%M:%S'} - " \
      "#{(Time.now + (showing_movie.duration * 60)).strftime '%H:%M:%S'}»"
    end

    private

    def hall(color, attr_hash)
      check_hall(color, attr_hash)
      @halls[color] = attr_hash
    end

    def period(time, &block)
      @periods << PeriodBuilder.new(time, &block).period
    end

    VALIDATIONS_HALL = {
      type: ->(attr_hash) { attr_hash.is_a?(Hash) },
      count: ->(attr_hash) { attr_hash.size == 2 },
      title: ->(attr_hash) { attr_hash[:title].is_a? String },
      places: ->(attr_hash) { attr_hash[:places].is_a?(Integer) && attr_hash[:places] >= 0 }
    }.freeze

    def check_hall(color, attr_hash)
      raise HallError, "Invalid hall #{color}" unless color.is_a? Symbol
      VALIDATIONS_HALL.each do |field, validation|
        raise HallError, "Invalid #{field}: #{attr_hash}" unless validation.call(attr_hash)
      end
    end

    VALIDATIONS_PERIODS = {
      time: ->(t) { t.is_a?(Range) },
      description: ->(d) { d.is_a?(String) },
      price: ->(p) { p.is_a?(Integer) || p > 0 },
      filters: ->(f) { f.is_a?(Hash) },
      hall: ->(h) { h.sample.is_a?(Symbol) }
    }.freeze

    def check_periods
      @periods.map do |period|
        VALIDATIONS_PERIODS.each do |field, validation|
          val = period.send(field)
          raise PeriodError, "Invalid #{field}: #{val}" unless validation.call(val)
        end
      end
    end

    def check_schedule
      @periods
        .combination(2)
        .select { |p1, p2| p1.covers?(p2) }
        .map do |period1, period2|
        hall_title = @halls[(period1.hall & period2.hall).first][:title]
        raise ScheduleError, "Сеансы: '#{period1.description}' и '" \
        "#{period2.description}' пересекаются в зале: '" \
        "#{hall_title}' в период с #{period2.time.first} по #{period1.time.last}"
      end
    end
  end
end
