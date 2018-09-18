require 'csv'
require 'date'
require 'money'
require_relative '../lib/cash_box'
require_relative '../lib/movie_collection'
require_relative '../lib/movie'

# begin
#   collection = Imdb::MovieCollection.new('../lib/movies.txt')
#   netflix = Imdb::Netflix.new('../lib/movies.txt')
#   theatre = Imdb::Theatre.new('../lib/movies.txt')
# rescue Imdb::Movie::ClassNotFound => e
#   p e.message
# end

# p collection.all
# p collection.genres
# p collection.sort_by(:director)
# puts collection.top_five_movies_by_duration
# puts collection.ten_comedies
# p collection.directors.inspect
# p collection.not_country_movies('USA')
# p collection.stat_by_month
# p collection.filter(title: 'Persona', year: 1966, country: "Sweden")
# p collection.stats(:director)


# begin
#   p collection.all.first.has_genre?('Crime')
#   p collection.all.first.has_genre?('Tragedy')
# rescue Imdb::Movie::GenreNotExist => e
#   p e.message
# end

# begin
#     p netflix.how_much?('Monsters')
#     p netflix.how_much?('Mo')
#     p netflix.how_much?('Monters')
# rescue Imdb::Netflix::MovieByTitleNotFound => e
#     puts e.message
# end

# begin
#     netflix.pay(-1)
# rescue Imdb::Netflix::NegativeAmountEntered => e
#     puts e.message
# end

# begin
#     netflix.pay(10)
#     netflix.show(period: :new, genre: 'Comey', year: 2000..2018)
# rescue Imdb::Netflix::MoviesByPatternNotFound => e
#     puts e.message
# end

# begin
#     netflix.pay(1)
#     netflix.show(genre: 'Comedy', year: 2000..2018)
#     netflix.show(title: /ter/i)
# rescue Imdb::Netflix::NotEnoughMoney => e
#     puts e.message
# end

# p netflix.balance.format
# p Imdb::Netflix.cash

# begin
#     p theatre.when?('The Great Dictator')
#     p theatre.when?('Terminator')
# rescue Imdb::Theatre::MovieNotShowing => e
#     puts e.message
# end

# begin
#     theatre.buy_ticket
#     theatre.buy_ticket
# rescue Imdb::Theatre::PeriodNotFound => e
#     puts e.message
# end

# p theatre.cash

# begin
#     theatre.show('Morning')
#     theatre.show('Night')
# rescue Imdb::Theatre::PeriodNotFound => e
#     puts e.message
# end

# begin
#     Imdb::Netflix.take('Bank')
#     Imdb::Netflix.take('Robbery')
# rescue CashBox::CallPolice => e
#     p e.message
# end

# begin
#     theatre.take('Bank')
#     theatre.take('Robbery')
# rescue CashBox::CallPolice => e
#     p e.message
# end

# p Imdb::MovieCollection.new('../lib/movies.txt').reject { |movie| movie.year < 2009 }.count
# p Imdb::MovieCollection.new('../lib/movies.txt').select { |movie| movie.year < 2009 }.count

# netflix.pay(100)

# p netflix.show(title: 'Persona', year: 1964...1970, country: "Sweden")

# netflix.define_filter(:new_sci_fi) { |movie| movie.period == :new && movie.genre.include?('Sci-Fi') }
# p netflix.show(new_sci_fi: true)

# netflix.define_filter(:new_sci_fi) { |movie, year| movie.year > year && movie.genre.include?('Sci-Fi') }
# p netflix.show(new_sci_fi: 2010, country: 'USA', title: 'Interstellar')

# netflix.define_filter(:newest_sci_fi, from: :new_sci_fi, arg: 2014)
# p netflix.show(newest_sci_fi: true, country: "Australia")

# p netflix.user_filters

# p netflix.by_genre.comedy

#puts netflix.by_country.usa

#p netflix.by_country.new_zealand

#p netflix.map(&:country).uniq.sort








# theatre =
#   Imdb::Theatre.new('../lib/movies.txt') do
#     hall :blue, title: 'Синий зал', places: 50
#     hall :green, title: 'Зелёный зал (deluxe)', places: 12
#     hall :red, title: 'Красный зал', places: 100

#     period '09:00'..'11:00' do
#       description 'Утренний сеанс'
#       filters genre: 'Comedy', year: 1940..1980
#       price 10
#       hall :red, :blue
#     end

#     period '11:00'..'16:00' do
#       description 'Спецпоказ'
#       title 'The Terminator'
#       price 50
#       hall :green
#     end

#     period '16:00'..'20:00' do
#       description 'Вечерний сеанс'
#       filters genre: ['Action', 'Drama'], year: 2007..Time.now.year
#       price 20
#       hall :red, :blue
#     end

#     period '19:00'..'22:00' do
#       description 'Вечерний сеанс для киноманов'
#       filters year: 1900..1945, exclude_country: 'USA'
#       price 30
#       hall :green, :red
#     end
#   end

#theatre = Imdb::Theatre.new('../lib/movies.txt')

#theatre.show('20:00')
#p theatre.when?("The Great Dictator")
#p theatre.buy_ticket
#p theatre.check_schedule

