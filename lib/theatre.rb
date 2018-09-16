module Imdb
  class Theatre < MovieCollection
    require_relative 'period'
    include CashBox

    attr_reader :hall

    PeriodNotFound    = Class.new(StandardError)
    MovieNotShowing = Class.new(StandardError)
    PeriodsError          = Class.new(StandardError)

      DEFAULT_SCHEDULE = {
        morning: {
          time: ('09:00'..'11:00'),
          filters: { period: :ancient },
          price: 3
        },
        afternoon: {
          time: ('12:00'..'17:00'),
          filters: { genre: %w[Comedy Adventure] },
          price: 5
        },
        evening: {
          time: ('18:00'..'23:00'),
          filters: { genre: %w[Drama Horror] },
          price: 10
        }
      }.freeze

    def initialize(file, &blk)
      super(file)
      @hall = Hash.new
      @periods = Array.new
      instance_eval(&blk) if block_given?
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
            raise PeriodsError, "Сеансы: '#{period1.description}' и '#{period2.description}' пересекаются в зале: '#{hall_title}' в период с #{period2.time.first} по #{period1.time.last}"
          end
    end

    def when?(title)
      movie = filter(title: title).sample
      if @periods.empty?
        DEFAULT_SCHEDULE.find_all do |_per, schedule|
          raise MovieNotShowing, 'Movie not showing' if filter(schedule[:filters]).count(movie).zero?
          filter(schedule[:filters]).include? movie
        end
      else
        periods = @periods.find_all do |period|
            raise MovieNotShowing, 'Movie not showing' if filter(period.filter).count(movie).zero?
            filter(period.filter).include? movie
          end.map(&:time)
        DEFAULT_SCHEDULE.find_all { |_per, schedule| periods.any? { |time_range| time_range.first.to_i >= schedule[:time].first.to_i && time_range.last.to_i <= schedule[:time].last.to_i } }
      end.to_h.keys
    end

    def buy_ticket
      time_now = Time.now.strftime "%H:%M"
      cost = if @periods.empty?
                   DEFAULT_SCHEDULE.select { |_per, schedule| schedule[:time].cover? time_now }.map { |_per, schedule| schedule[:price] }
                 else
                   @periods.select { |period| period.time.cover? time_now }.map(&:cost).first
                 end
      pay(cost)
      show(time_now)
    end

    def show(time)
      options = if @periods.empty?
                        raise PeriodNotFound, "Period #{time} not found" if DEFAULT_SCHEDULE.find_all { |_per, schedule| schedule[:time].cover? time }.empty?
                        DEFAULT_SCHEDULE.select { |_per, schedule| schedule[:time].cover? time }.map { |_per, schedule| schedule[:filters] }.first
                      else
                        raise PeriodNotFound, "Period #{time} not found" if @periods.find_all { |period| period.time.cover? time }.empty?
                        @periods.select { |period| period.time.cover? time }.map { |period| period.filter }.first
                      end
      showing_movie = filter(options).max_by { |movie| movie.rating + rand(100) }
      puts "«Now showing: #{showing_movie.title} (#{showing_movie.year}; #{showing_movie.genre.join(', ')}; #{showing_movie.country}) #{Time.now.strftime '%H:%M:%S'} - #{(Time.now + (showing_movie.duration * 60)).strftime '%H:%M:%S' }»"
    end
  end
end
