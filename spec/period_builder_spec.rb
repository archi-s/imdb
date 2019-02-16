require_relative 'config/spec_helper'

describe Imdb::Theatre do

  let(:theatre_with_schedule) do
   described_class.new('../data/movies.txt') do
      hall :blue, title: 'Синий зал', places: 50
      hall :green, title: 'Зелёный зал (deluxe)', places: 12
      hall :red, title: 'Красный зал', places: 100

      period '16:00'..'20:00' do
        description 'Вечерний сеанс'
        filters genre: ['Action', 'Drama'], year: 2007..Time.now.year
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
  end

  let(:theatre_with_bad_schedule) do
   described_class.new('../data/movies.txt') do
      hall :blue, title: 'Синий зал', places: 50
      hall :green, title: 'Зелёный зал (deluxe)', places: 12
      hall :red, title: 'Красный зал', places: 100

      period '16:00'..'20:00' do
        description 'Вечерний сеанс'
        filters genre: ['Action', 'Drama'], year: 2007..Time.now.year
        price 20
        hall :red, :blue
      end

      period '19:00'..'22:00' do
        description 'Вечерний сеанс для киноманов'
        filters year: 1900..1945, exclude_country: 'USA'
        price 30
        hall :green, :red
      end
    end
  end

  let(:theatre_with_bad_hall) do
   described_class.new('../data/movies.txt') do
      hall :blue, title: 'Синий зал', places: -1
    end
  end

  let(:theatre_with_bad_period) do
   described_class.new('../data/movies.txt') do
      hall :blue, title: 'Синий зал', places: 50

      period '16:00'..'20:00' do
        description 'Вечерний сеанс'
        filters genre: ['Action', 'Drama'], year: 2007..Time.now.year
        price 20
        hall "red"
      end
    end
  end

 let(:theatre_without_schedule) { described_class.new('../data/movies.txt') }

  describe '#check_theatre' do
    it '_with_schedule' do
       expect( theatre_with_schedule ).to all be_a Imdb::Movie
    end

    it '_with_bad_schedule' do
      expect{ theatre_with_bad_schedule }.to raise_error(Imdb::Theatre::ScheduleError, /19:00 по 20:00/)
    end

    it '_with_bad_hall' do
      expect{ theatre_with_bad_hall }.to raise_error(Imdb::Theatre::HallError, "Invalid places: {:title=>\"Синий зал\", :places=>-1}")
    end

    it '_with_bad_period' do
      expect{ theatre_with_bad_period }.to raise_error(Imdb::Theatre::PeriodError, "Invalid hall: [\"red\"]")
    end

    it '_without_schedule' do
      expect( theatre_without_schedule ).to all be_a Imdb::Movie
    end
  end
end
