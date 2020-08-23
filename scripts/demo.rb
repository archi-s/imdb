# require_relative '../lib/imdb'
# collection = Imdb::MovieCollection.new(Imdb::MOVIE_FILE_PATH)
# p collection.all.first.actors
# puts collection.select { |movie| movie.duration > 120 && movie.year <= 2005 }
# p collection.stat_by_month
# puts collection.sort_by(:year)
# begin
#   puts collection.filter(title: /raduat/i, year: 1966..1968, rating: 7..9, \
#                          actors: /Dustin Hoff/i, genre: %w[Comedy Drama], country: ['USA', /Jap/i])
#   puts collection.filter(_title: /raduat/i, year: 1966..1968, _rating: 7..9, \
#                          actors: /Dustin Hoff/i, genre: %w[Comedy Drama], country: ['USA', /Jap/i])
# rescue StandardError => e
#   p e.message
# end
# begin
#   p collection.stats(:year)
#   p collection.stats(:_year)
# rescue Imdb::MovieCollection::ParamsNotExist => e
#   p e.message
# end
# begin
#   p collection.first.genre?('Drama')
#   p collection.first.genre?('Comedy')
#   p collection.first.genre?('_Comedy')
# rescue Imdb::Movie::GenreNotFound => e
#   p e.message
# end
# p collection.first.period
# p Imdb::Movie::KEYS.map { |field| collection.first.respond_to?(field) }

# netflix = Imdb::Netflix.new(Imdb::MOVIE_FILE_PATH)
# begin
#   p netflix.how_much?('The Terminator')
#   p netflix.how_much?('The Terminator 5')
# rescue Imdb::Netflix::MovieNotFound => e
#   p e.message
# end
# begin
#   netflix.account(10)
#   p Imdb::Netflix.cash
#   netflix.account(-10)
# rescue Imdb::Netflix::CannotNegative => e
#   p e.message
# end
# begin
#   netflix.account(10)
#   Imdb::Netflix.cash
#   Imdb::Netflix.take('Bank')
#   netflix.account(10)
#   Imdb::Netflix.take('_Bank')
# rescue Imdb::CashBox::Robbery => e
#   p e.message
# end
# begin
#   netflix.show(genre: 'Comedy', period: :classic)
# rescue Imdb::Netflix::NotEnoughMoney => e
#   p e.message
# end
# begin
#   netflix.account(120)
#   netflix.show(genre: 'Comedy', period: :classic)
#   netflix.show(genre: '_Comedy', period: :classic)
# rescue Imdb::Netflix::MovieNotFound => e
#   p e.message
# end
# begin
#   netflix.account(5000)
#   netflix.define_filter(:classic_comedy) { |movie| movie.period == :classic && movie.genre.include?('Comedy') }
#   netflix.define_filter(:new_sci_fi) { |movie, year| movie.year > year && movie.genre.include?('Sci-Fi') }
#   netflix.define_filter(:newest_sci_fi, from: :new_sci_fi, arg: 2014)
#   netflix.show(genre: 'Comedy', period: :classic)
#   netflix.show { |movie| movie.period == :classic && movie.genre.include?('Comedy') }
#   netflix.show(genre: 'Comedy', period: :classic) { |movie| movie.period == :classic && movie.genre.include?('Comedy') }
#   netflix.show(classic_comedy: true)
#   netflix.show(classic_comedy: true) { |movie| movie.period == :classic && movie.genre.include?('Comedy') }
#   netflix.show(genre: 'Comedy', period: :classic, classic_comedy: true) \
#     { |movie| movie.period == :classic && movie.genre.include?('Comedy') }
#   netflix.show(new_sci_fi: 2010)
#   netflix.show(newest_sci_fi: true)
#   netflix.show(new_sci_fi: 2010) { |movie| movie.period != :new }
# rescue Imdb::Netflix::MovieNotFound => e
#   p e.message
# end
# p netflix.genre.comedy
# p netflix.country.usa

# theatre =
#   Imdb::Theatre.new(Imdb::MOVIE_FILE_PATH) do
#     hall :red, title: 'Красный зал', places: 100
#     hall :blue, title: 'Синий зал', places: 50
#     hall :green, title: 'Зелёный зал (deluxe)', places: 12

#     period '09:00'..'11:00' do
#       description 'Утренний сеанс'
#       pattern genre: 'Comedy', year: 1900..1980
#       price 100
#       hall :red, :blue
#     end

#     period '11:00'..'16:00' do
#       description 'Спецпоказ'
#       title 'The Terminator'
#       price 500
#       hall :green, :blue
#     end

#     period '16:00'..'20:00' do
#       description 'Вечерний сеанс'
#       pattern genre: %w[Action Drama], year: 2007..Time.now.year
#       price 200
#       hall :red, :blue
#     end

#     period '19:00'..'22:00' do
#       description 'Вечерний сеанс для киноманов'
#       pattern year: 1900..1945, exclude_country: 'USA'
#       price 300
#       hall :green
#     end
#   end
# begin
#   theatre.show('23:00')
#   theatre.show('07:00')
# rescue Imdb::Theatre::Closed => e
#   p e.message
# end
# begin
#   p theatre.when?('Underground')
#   p theatre.when?('The Terminator')
# rescue Imdb::Theatre::MovieNotShowing => e
#   p e.message
# end
# begin
#   p theatre.cash
#   theatre.buy_ticket
#   p theatre.cash
#   theatre.buy_ticket
#   p theatre.cash
#   p theatre.take('Bank')
#   p theatre.take('_Bank')
# rescue Imdb::Theatre::Closed, Imdb::CashBox::Robbery => e
#   p e.message
# end
# p theatre.genre.comedy
