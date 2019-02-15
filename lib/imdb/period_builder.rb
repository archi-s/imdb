module Imdb
  class Theatre
    require_relative 'period'

    class PeriodBuilder
      attr_reader :period
      def initialize(time, &block)
        @period = Period.new
        @period.time = time
        instance_eval(&block)
      end

      private

      KNOWN_FILTERS =
        %i[url title year country release genre duration rating director actors].freeze

      %i[description filters price].each do |sym|
        define_method(sym) do |arg|
          @period.send("#{sym}=", arg)
        end
      end

      def hall(*hall)
        @period.hall = hall
      end

      def method_missing(meth, arg)
        if KNOWN_FILTERS.include?(meth)
          filters(meth => arg)
        else
          super
        end
      end

      def respond_to_missing?(meth, _arg)
        KNOWN_FILTERS.include?(meth)
      end
    end
  end
end
