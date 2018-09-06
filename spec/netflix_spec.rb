require_relative 'spec_helper'

describe Imdb::Netflix do
  subject { described_class.new('../lib/movies.txt') }

  describe '#how_much?' do
    it 'How mach?' do
      expect(subject.how_much?('Groundhog Day')).to eq(['$3.00'])
    end
  end

  describe '#pay' do
    it 'increases Netflix\'s amount of money' do
      expect { subject.pay(10) }.to change(subject, :balance).from(Money.new(0, 'USD')).to(Money.new(1000, 'USD'))
    end

    it 'fails on negative amounts' do
      expect { subject.pay(-5) }.to raise_error(Imdb::Netflix::NegativeAmountEntered)
    end
  end

  describe '#show' do
    it 'Film not found' do
      subject.pay(10)
      expect{subject.show(title: 'Groundhog Days')}.to raise_error(Imdb::Netflix::MoviesByPatternNotFound)
    end

    it 'When not enough money' do
      subject.pay(1)
      expect{subject.show(title: /ter/i)}.to raise_error(Imdb::Netflix::NotEnoughMoney)
    end

    it 'When showing movie by default filter' do
      subject.pay(10)
      expect{subject.show(title: 'Groundhog Day')}
      .to output(/^«Now showing: Groundhog Day \(1993; Comedy, Romance; USA\) \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
      .and change(subject, :balance).by(Money.new(-300, 'USD'))
    end

    it 'When showing movie by personal filter' do
      subject.pay(10)
      subject.define_filter(:new_sci_fi) { |movie| movie.period == :new && movie.genre.include?('Sci-Fi') }
      expect{subject.show(new_sci_fi: true)}
      .to output(/«Now showing: .* \(20[0-9][0-9]; .*Sci-Fi.*; USA\) \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
      .and change(subject, :balance).by(Money.new(-500, 'USD'))
    end

    it 'When showing movie by mix personal filter and default filter' do
      subject.pay(10)
      subject.define_filter(:new_sci_fi) { |movie| movie.period == :new && movie.genre.include?('Sci-Fi') }
      expect{subject.show(new_sci_fi: true, country: 'USA')}
      .to output(/^«Now showing: .* \(20[0-9][0-9]; .*Sci-Fi.*; USA\) \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
      .and change(subject, :balance).by(Money.new(-500, 'USD'))
    end

    it 'When a movie is displayed on a personal filter based on a personal filter with a default filter' do
      subject.pay(10)
      subject.define_filter(:new_sci_fi) { |movie| movie.period == :new && movie.genre.include?('Sci-Fi') }
      subject.define_filter(:newest_sci_fi, from: :new_sci_fi, arg: 2014)
      expect{subject.show(new_sci_fi: true, country: 'Australia')}
      .to output(/^«Now showing: .* \(20[1-9][4-9]; .*Sci-Fi.*; Australia\) \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
      .and change(subject, :balance).by(Money.new(-500, 'USD'))
    end

  end

end
