IMDB is a console application to manipulate the data from the list of top 250 IMDB movies.
==========

Installation
-------------------
```ruby
$ gem install imdb
```

Before you can use all the features of the library you want to connect a data file with movies in ```imdb/data/movies.txt```

MovieCollection
------------------
MovieCollection, created in the application, allows you to extract data and show filtered and sorted lists of movies, based on different criteria, also it can display any statistics on films.

```ruby
  # make collection of movies
  movies = Imdb::MovieCollection.new(file_name)
  # => <Imdb::MovieCollection:0x00000002ab6da8>

  #show comedies
  movies.filter(genre: 'Comedy')
  # => <Imdb::ModernMovie:0x00000002ff7038>
  # => <Imdb::AncientMovie:0x00000002fdcaa8>
  # => <Imdb::NewMovie:0x00000002fd5ca8>
  # => ...

  # show sorted list movies by year
  movies.sort_by(:year)
  # => The Kid - 1921
  # => The Gold Rush - 1925
  # => The General - 1926
  # => Metropolis - 1927
  # =>  ...

  # show count of movies maked each author
  movies.stats(:author)
  # => {"Adam Elliot"=>1, "Akira Kurosawa"=>6, "Alejandro González Iñárritu"=>1, ... }

  # get first movie
  movie = movies.all.first

  # number famous actors played in this movie
  movie.actors.count
  # => 3

  # Arnold Shwarzenegger played in this movie
  movie.actors.include?('Arnold Shwarzenegger')
  # => false
```


Netflix
----------------
Netflix and Theatre are cinemas based on MovieCollection have cashboxes that can accept payments and sell tickets.

```ruby
  # make online cinema Netflix
  online = Imdb::Netflix.new(file_name)
  # => #<Imdb::Netflix:0x000000021e0558>

  # show newest Drama
  online.show(genre: 'Drama', period: :new)
  # => Downfall — новинка, вышло 12 лет назад!

  # create component filter
  movies = online.show do |movie|
    !movie.title.include?('Terminator') && \
      movie.genre[0].include?('Action') && \
      movie.year > 2003
  end
  # genre of movies is Action and not have Terminator and newer 2003
  # => Elite Squad: The Enemy Within — новинка, вышло 6 лет назад!

  # put cash to cashbox of Netflix
  online.pay(35)
  # => 35.00

  # You can filter movies by genre or by country:
  netflix.by_genre.crime
  netflix.by_country.usa

  # You can define custom filters:
  netflix.define_filter(:new_sci_fi) { |movie| !movie.title.include?('Terminator') && movie.genre.include?('Action') && movie.year > 2003 }
  # Show results
  netflix.show(new_sci_fi: true)

  # Custom filter with argument.
  netflix.define_filter(:new_action) { |movie, year| movie.year > year && movie.genre.include?('Action') }
  # Show results
  netflix.show(new_action: 2003)

  # You can also define new filter by inheriting from an existing one.
  netflix.define_filter(:newest_action, from: :new_action, arg: 2014)

Build HTML page with collection data
--------------------
  Parser class makes requests to TMDB API to grab some data, so you need to set your TMDB API Key in 'config/tmdb_api_key.env'.

  # Create new parser instance:
  collection = Imdb::MovieCollection.new('./lib/movies.txt')
  Imdb::Parser.new(collection).run.write('../data/data.yml')

  Parser grabs movie poster, budget and alternative titles from tmdb and imdb.

  # Now you can save your data to html:
  Imdb::CollectionRenderer.new(collection).write('../views/netflix.html')
```

Theatre
-------------------

```ruby
  # make usual cinema Theatre
  theatre =
    Imdb::Theatre.new do
      hall :red, title: 'Красный зал', places: 100
      hall :blue, title: 'Синий зал', places: 50
      hall :green, title: 'Зелёный зал (deluxe)', places: 12

      period '09:00'..'12:00' do
        description 'Утренний сеанс'
        filters genre: 'Comedy', year: 1900..1980
        price 10
        hall :red, :blue
      end

      period '12:00'..'16:00' do
        description 'Спецпоказ'
        title 'The Terminator'
        price 50
        hall :green
      end

      period '16:00'..'20:00' do
        description 'Вечерний сеанс'
        filters genre: %w(Action Drama), year: 2007..Time.now.year
        price 20
        hall :red, :blue
      end

      period '19:00'..'22:00' do
        description 'Вечерний сеанс для киноманов'
        filters year: 1900..1945, exclude_country: 'USA'
        price 30
        hall :green
      end
  end
  # => <Imdb::Netflix:0x000000011152a0>

  # you can add period into Theatre
  theatre.period '21:00'..'23:00' do
    description 'Еще один сеанс'
    filters genre: 'Sci-Fi', year: 1900..1980
    price 13
    hall :red
  end

  # you can buy a ticket
  theatre.buy_ticket('10:20')
  # => Утренний сеанс - 09:00..12:00 : Фильм: The Gold Rush
  theatre.buy_ticket('13:20')
  # => Спецпоказ - 12:00..16:00 : Фильм: The Terminator
  theatre.buy_ticket('17:20')
  # => Вечерний сеанс - 16:00..20:00 : Фильм: Interstellar
  theatre.buy_ticket('19:20', hall: :green)
  # => Вечерний сеанс для киноманов - 19:00..22:00 : Фильм: The Maltese Falcon

  # if you want you can check the money in cashbox of Theatre
  theatre.cash
  # => 110.00

  # yet you can spend cash collection into cashbox of Theatre
  theatre.take('Bank')
  # => Проведена инкассация
  # => 0.00
```

Run library from CLI
----------------
  There is an executable file (bin/netflix), which can be run from the command line
  passing it parameters, and receive the filtered data.

```ruby
  # run
  $ bin/netflix netflix --pay 25 --show genre:Comedy
  # => The General — старый фильм (1926 год)
```

License
---------------
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Author
--------------
Arthur H.
