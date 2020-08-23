module Imdb
  module MovieConstruct
    include Virtus.model
    class SplitArray < Virtus::Attribute
      def coerce(value)
        value.split(',')
      end
    end

    class ToInteger < Virtus::Attribute
      def coerce(value)
        value.to_i
      end
    end

    attribute :link, String
    attribute :title, String
    attribute :year, Integer
    attribute :country, String
    attribute :release, String
    attribute :genre, SplitArray
    attribute :duration, ToInteger
    attribute :rating, Float
    attribute :director, String
    attribute :actors, SplitArray
    attribute :collection, @collection
  end
end
