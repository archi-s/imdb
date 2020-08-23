module Imdb
  class MethodChain
    include Virtus.model

    attribute :key
    attribute :collection

    private

    def method_missing(value)
      value = value.to_s.tr('_', '-') if value.to_s.include?('_')
      collection.filter(key => /#{value}/i)
    end

    def respond_to_missing?
      Imdb::Movie::KEYS.include? key
    end
  end
end
