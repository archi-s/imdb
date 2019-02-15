class Range
  def overlaps?(time)
    last > time.first
  end
end

module Imdb
  class Theatre
    class Period
      attr_accessor :time, :description, :filters, :price, :hall

      def covers?(period)
        time.overlaps?(period.time) && (hall & period.hall).any?
      end
    end
  end
end
