module Imdb
  class Theatre
    class Schedule
      IntersectsError = Class.new(Error)
      HallError = Class.new(Error)
      PeriodError = Class.new(Error)

      attr_reader :halls, :periods

      def initialize(&blk)
        @halls = []
        @periods = []
        instance_eval(&blk)
        check_periods
        schedule_intersection
      end

      private

      def hall(color, opts)
        check_hall(color, opts)
        halls << OpenStruct.new(opts.merge(hall: color))
      end

      def period(time, &blk)
        periods << Period.new(time, &blk)
      end

      VALIDATIONS_HALL = {
        type: ->(opts) { opts.is_a? Hash },
        count: ->(opts) { opts.size == 2 },
        title: ->(opts) { opts[:title].is_a? String },
        places: ->(opts) { opts[:places].is_a?(Integer) && opts[:places] >= 0 }
      }.freeze

      def check_hall(color, opts)
        raise HallError, "Invalid hall #{color}" unless color.is_a? Symbol
        VALIDATIONS_HALL.each do |field, validation|
          raise HallError, "Invalid #{field}: #{opts}" unless validation.call(opts)
        end
      end

      VALIDATIONS_PERIODS = {
        time: ->(t) { t.is_a? Range },
        description: ->(d) { d.is_a? String },
        price: ->(p) { p.is_a?(Integer) && p > 0 },
        pattern: ->(f) { f.is_a?(Hash) && !f.values.all?(&:nil?) },
        hall: ->(h) { h.all? { |hall| hall.is_a? Symbol } }
      }.freeze

      def check_periods
        periods.map do |period|
          VALIDATIONS_PERIODS.each do |field, validation|
            value = period.send(field)
            raise PeriodError, "Invalid #{field}: #{value}" unless validation.call(value)
          end
        end
      end

      def schedule_intersection
        periods.combination(2).select { |p1, p2| p1.intersects? p2 }.map do |p1, p2|
          raise IntersectsError, "#{p1.description} intersects with #{p2.description} " \
          "in the #{(p1.hall & p2.hall)} at #{p2.time.first} - #{p1.time.last}"
        end
      end
    end
  end
end
