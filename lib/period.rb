module Imdb
  class Theatre
    class Period
      class ::Range
        def overlaps?(time)
          last > time.first
        end
      end

      KNOWN_FILTERS = %i[url title year country release genre duration rating director actors].freeze

      attr_reader :time, :specification, :filter, :cost, :halls

      def initialize(time, &blk)
        @time = time
        instance_eval(&blk)
      end

      def description(description)
        @specification = description
      end

      def filters(filters)
        @filter = filters
      end

      def price(price)
        @cost = price
      end

      def hall(*hall)
        @halls = hall
      end

      def covers?(p2)
        time.overlaps?(p2.time) && (halls & p2.halls).any?
      end

      def method_missing(meth, arg)
        if KNOWN_FILTERS.include?(meth)
          filters(meth => arg)
        else
          super
        end
      end
    end
  end
end
