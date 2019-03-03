module CashBox
  I18n.config.available_locales = :en

  CallPolice = Class.new(StandardError)

  attr_reader :cash

  def pay(money)
    @cash ||= Money.new(0, 'USD')
    @cash += Money.new(money, 'USD')
  end

  def take(who)
    raise CallPolice, 'Call police' unless who == 'Bank'
    @cash = Money.new(0, 'USD')
    puts "Проведена инкассация. Наличных в кассе #{@cash.format}"
  end
end
