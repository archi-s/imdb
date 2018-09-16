require_relative 'spec_helper'

describe Imdb::Theatre do
  subject { described_class.new('../lib/movies.txt') }

  describe '#when?' do
    it 'Testing when movie showing' do
      expect(subject.when?('The Great Dictator')).to eq(["Morning", "Afternoon", "Evening"])
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
      expect{subject.show('Evening')}.to output(/«Now showing: .* \([1-2]\d{3}; .*; .*\) \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
    end

    it 'Testing not exist period' do
      expect{subject.show('Night')}.to raise_error(Imdb::Theatre::PeriodNotFound)
    end
  end
end
