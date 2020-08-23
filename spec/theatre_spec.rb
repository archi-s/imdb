require_relative 'spec_helper'

describe Imdb::Theatre do

  subject { described_class.new("./data/movies.txt") }

  let(:theatre_with_schedule) do
   described_class.new('./data/movies.txt') do
      hall :blue, title: 'Синий зал', places: 50
      hall :green, title: 'Зелёный зал (deluxe)', places: 12
      hall :red, title: 'Красный зал', places: 100

      period '16:00'..'20:00' do
        description 'Вечерний сеанс'
        pattern genre: ['Action', 'Drama'], year: 2007..Time.now.year
        price 20
        hall :red, :blue
      end

      period '19:00'..'22:00' do
        description 'Вечерний сеанс для киноманов'
        pattern year: 1900..1945, exclude_country: 'USA'
        price 30
        hall :green
      end
    end
  end

  let(:theatre_with_bad_schedule) do
   described_class.new('./data/movies.txt') do
      hall :blue, title: 'Синий зал', places: 50
      hall :green, title: 'Зелёный зал (deluxe)', places: 12
      hall :red, title: 'Красный зал', places: 100

      period '16:00'..'20:00' do
        description 'Вечерний сеанс'
        pattern genre: ['Action', 'Drama'], year: 2007..Time.now.year
        price 20
        hall :red, :blue
      end

      period '19:00'..'22:00' do
        description 'Вечерний сеанс для киноманов'
        pattern year: 1900..1945, exclude_country: 'USA'
        price 30
        hall :green, :red
      end
    end
  end

  let(:theatre_with_bad_hall) do
   described_class.new('./data/movies.txt') do
      hall :blue, title: 'Синий зал', places: -10

      period '16:00'..'20:00' do
        description 'Вечерний сеанс'
        pattern genre: ['Action', 'Drama'], year: 2007..Time.now.year
        price 20
        hall :red
      end
    end
  end

  let(:theatre_with_bad_period) do
   described_class.new('./data/movies.txt') do
      hall :blue, title: 'Синий зал', places: 50

      period '16:00'..'20:00' do
        description 'Вечерний сеанс'
        pattern genre: ['Action', 'Drama'], year: 2007..Time.now.year
        price '20'
        hall :red
      end
    end
  end

  let(:theatre_without_schedule) { subject }

  describe '#check_theatre' do
    it '_with_schedule' do
       expect( theatre_with_schedule ).to all be_a Imdb::Movie
    end

    it '_with_bad_schedule' do
      expect{ theatre_with_bad_schedule }.to raise_error(Imdb::Theatre::Schedule::IntersectsError, "Вечерний сеанс intersects with Вечерний сеанс для киноманов in the [:red] at 19:00 - 20:00")
    end

    it '_with_bad_hall' do
      expect{ theatre_with_bad_hall }.to raise_error(Imdb::Theatre::Schedule::HallError)
    end

    it '_with_bad_period' do
      expect{ theatre_with_bad_period }.to raise_error(Imdb::Theatre::Schedule::PeriodError)
    end

    it '_without_schedule' do
      expect( theatre_without_schedule ).to all be_a Imdb::Movie
    end
  end

  describe '#show' do
    it "Testing show" do
      expect{subject.show('09:00')}.to output(/^«[a-z].*[a-z]\s\d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
    end
    it "Testing not exist period" do
      expect{subject.show('05:00')}.to raise_error(Imdb::Theatre::Closed, "At 05:00 o’clock the cinema is closed")
    end
  end

  describe '#when?' do
    it "Testing when" do
      expect(subject.when?('Gone with the Wind')).to eq(["09:00".."19:00", "18:00".."23:00"])
    end
  end

  describe '#buy_ticket' do
    it "Testing buy ticket" do
      time_now = Time.now.strftime "%H:%M"
      if subject.schedule.periods.any? { |period| period.time === time_now }
        expect{subject.buy_ticket}.to output(/^«[a-z].*[a-z]\s\d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
      else
        expect{subject.buy_ticket}.to raise_error(Imdb::Theatre::Closed, "At #{time_now} o’clock the cinema is closed")
      end
    end
  end
end
















# describe Imdb::Theatre do

#   subject { described_class.new("./data/movies.txt") }

#   describe '#show' do
#     it "Testing show" do
#       expect{subject.show('09:00')}.to output(/^«[a-z].*[a-z]\s\d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
#     end
#     # it "Testing not exist period" do
#     #   expect{subject.show('23:00')}.to raise_error(Imdb::Theatre::Closed, "At 23 o’clock the cinema is closed")
#     # end
#   end

#   describe '#when?' do
#     it "Testing when" do
#       expect(subject.when?('Gone with the Wind')).to eq(["09:00".."19:00", "18:00".."23:00"])
#     end
#   end

#   describe '#buy_ticket' do
#     it "Testing buy ticket" do
#       time_now = Time.now.strftime "%H:%M"
#       if subject.schedule.periods.any? { |period| period.time === time_now }
#         expect{subject.buy_ticket}.to output(/^«[a-z].*[a-z]\s\d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
#       else
#         #expect{subject.buy_ticket}.to raise_error(Imdb::Theatre::Closed, "At #{time_now} o’clock the cinema is closed")
#       end
#     end
#   end


# end
