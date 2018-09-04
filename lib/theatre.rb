module Imdb
  class Theatre < MovieCollection
    include CashBox

    PeriodNotFound    = Class.new(StandardError)
    MovieNotShowing = Class.new(StandardError)

    PERIODS = { 6..12   => { period: :ancient },
                          13..17 => { genre: ['Comedy', 'Adventure'] },
                          18..23 => { genre: ['Drama', 'Horror'] } }

    COST = { PERIODS.keys[0] => Money.new(300, 'USD'),
                    PERIODS.keys[1] => Money.new(500, 'USD'),
                    PERIODS.keys[2] => Money.new(1000, 'USD') }

    TIMES_OF_DAY = { 'Morning'   => PERIODS.values[0],
                                    'Afternoon' => PERIODS.values[1],
                                    'Evening'    => PERIODS.values[2] }

    def when?(title)
      movie = filter(title: title).sample
      TIMES_OF_DAY.select do |_period, pattern|
        raise MovieNotShowing, 'Movie not showing' if filter(pattern).count(movie).zero?
        filter(pattern).include? movie
      end.keys
    end

    def buy_ticket
      _time, money = COST.find { |time, _cost| time === Time.now.hour }
      _period, pattern = PERIODS.detect { |period, _pattern| period === Time.now.hour }
      times_of_day, _pattern = TIMES_OF_DAY.detect { |_times_of_day, sample| pattern == sample }
      pay(money)
      show(times_of_day)
    end

    def show(time)
      raise PeriodNotFound, "Period #{time} not found" if TIMES_OF_DAY[time].nil?
      showing_movie = filter(TIMES_OF_DAY[time]).max_by { |movie| movie.rating + rand(100) }
      puts "«Now showing: #{showing_movie.title} #{Time.now.strftime '%H:%M:%S'} - #{(Time.now + (showing_movie.duration * 60)).strftime '%H:%M:%S' }»"
    end
  end
end
