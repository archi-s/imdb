module Imdb
  class Theatre
    class Schedule
      class Period
        class ::Range
          def overlaps?(range)
            last > range.first
          end
        end
        UnknownScheduleKeys = Class.new(Error)

        PERIODS_KEYS = %i[description pattern price hall].freeze
        attr_reader :time
        def initialize(time, &blk)
          @time = time
          instance_eval(&blk)
        end

        def intersects?(period)
          time.overlaps?(period.time) && (hall & period.hall).any?
        end

        private

        def method_missing(field, *value)
          value = value.sample unless field == :hall
          if Imdb::Movie::KEYS.include? field
            define_singleton_method(:pattern) { instance_variable_set('@pattern', field => value) }
          elsif respond_to_missing? field
            define_singleton_method(field) { instance_variable_set("@#{field}", value) }
          else
            raise UnknownScheduleKeys, field.to_s
          end
        end

        def respond_to_missing?(field)
          PERIODS_KEYS.include?(field)
        end
      end
    end
  end
end
