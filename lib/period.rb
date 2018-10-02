module Imdb
  class Theatre
    class Period
      attr_accessor :time, :description, :filters, :price, :hall

      class ::Range
        def overlaps?(time)
          last > time.first
        end
      end

      def covers?(p2)
        time.overlaps?(p2.time) && (hall & p2.hall).any?
      end

    end
  end
end
