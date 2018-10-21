class PrepareToHaml
  require 'virtus'
  include Virtus.model

  class JoinString < Virtus::Attribute
    def coerce(value)
      value.join(', ')
    end
  end

  attribute :ru_title, String
  attribute :poster, String
  attribute :budget, Integer
  attribute :url, String
  attribute :title, String
  attribute :year, Integer
  attribute :country, String
  attribute :release, String
  attribute :genre, JoinString
  attribute :duration, Integer
  attribute :rating, Float
  attribute :director, String
  attribute :actors, JoinString

end
