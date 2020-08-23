module Imdb
  module CashBox
    I18n.enforce_available_locales = false

    Robbery = Class.new(Error)

    attr_reader :cash

    def cashbox(money)
      @cash ||= Money.new(0, 'USD')
      @cash += Money.new(money, 'USD')
    end

    def take(who)
      who == 'Bank' ? "Collection made. Balance: #{collection.format}" : raise(Robbery, 'Police called')
    end

    private

    def collection
      @cash = Money.new(0, 'USD')
    end
  end
end
