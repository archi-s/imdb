require_relative 'config/spec_helper'

describe Imdb::Theatre do
  subject { described_class.new('../data/movies.txt') }

  describe '#when?' do
    it 'Testing when movie showing' do
      expect(subject.when?('The Great Dictator')).to eq(["From 09:00 to 19:00", "From 12:00 to 17:00", "From 18:00 to 23:00"])
    end

    it 'Testing when movie not showing' do
      expect { subject.when?('Terminator') }.to raise_error(Imdb::Theatre::MovieNotShowing)
    end
  end

  describe '#buy_ticket' do
    it 'Testing buy ticket' do
      expect{subject.buy_ticket}.to output(/«Now showing: .* \([1-2]\d{3}; .*; .*\) \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
    end
  end

  describe '#show' do
    it 'Testing show' do
      expect{subject.show('20:00')}.to output(/«Now showing: .* \([1-2]\d{3}; .*; .*\) \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
    end

    it 'Testing not exist period' do
      expect{subject.show('24:00')}.to raise_error(Imdb::Theatre::PeriodNotFound)
    end
  end

end
