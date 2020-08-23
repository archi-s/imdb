require_relative 'spec_helper'

describe Imdb::Netflix do

  subject { described_class.new("./data/movies.txt") }

  describe '#how_much?' do
    it "How mach?" do
      expect(subject.how_much?("Groundhog Day")).to eq(Money.new(300, "USD"))
      expect{subject.how_much?("The Terminator 5")}.to raise_error(Imdb::Netflix::MovieNotFound, 'Movie The Terminator 5 not found')
    end
  end

  describe '#account' do
    it 'increases Netflix\'s amount of money' do
      expect { subject.account(100) }.to change(subject, :balance).from(Money.new(0, "USD")).to(Money.new(100, "USD"))
    end

    it 'fails on negative amounts' do
      expect { subject.account(-5) }.to raise_error(Imdb::Netflix::CannotNegative, 'Cannot be negative -5')
    end

    it 'returns the amount at the checkout' do
      expect(described_class.cash).to eq(Money.new(100, "USD"))
    end
  end

  describe '#show' do
    it "Film not found" do
      subject.account(500)
      expect{subject.show(title: "The Terminator 5")}.to raise_error(Imdb::Netflix::MovieNotFound)
    end

    it "When not enough money" do
      subject.account(100)
      expect{subject.show(title: /termina/i)}.to raise_error(Imdb::Netflix::NotEnoughMoney, 'Not enough: 2.00')
    end

    it "When showing movie by default filter" do
      subject.account(300)
      expect{subject.show(title: "Groundhog Day", genre: 'Comedy')}
      .to output(/^«Now showing: Groundhog Day \(1993; Comedy, Romance; USA\) \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
      .and change(subject, :balance).from(Money.new(300, "USD")).to(Money.new(0, "USD"))
    end

    it 'returns the movie transmitted by the block' do
      subject.account(500)
      expect{subject.show { |movie| movie.period == :new && movie.genre.include?('Sci-Fi') && movie.country == "USA" } }
      .to output(/«Now showing: .* \(20[0-9][0-9]; .*Sci-Fi.*; USA\) \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
      .and change(subject, :balance).by(Money.new(-500, 'USD'))
    end

    it 'When showing movie by personal filter' do
      subject.account(500)
      subject.define_filter(:new_sci_fi) { |movie| movie.period == :new && movie.genre.include?('Sci-Fi') && movie.country == "USA" }
      expect{subject.show(new_sci_fi: true)}
      .to output(/«Now showing: .* \(20[0-9][0-9]; .*Sci-Fi.*; USA\) \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
      .and change(subject, :balance).by(Money.new(-500, 'USD'))
    end

    it 'When showing movie by mix personal filter and default filter' do
      subject.account(500)
      subject.define_filter(:new_sci_fi) { |movie| movie.period == :new && movie.genre.include?('Sci-Fi') }
      expect{subject.show(new_sci_fi: true, country: 'USA')}
      .to output(/^«Now showing: .* \(20[0-9][0-9]; .*Sci-Fi.*; USA\) \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
      .and change(subject, :balance).by(Money.new(-500, 'USD'))
    end

    it 'When a movie is displayed on a personal filter based on a personal filter with a default filter' do
      subject.account(500)
      subject.define_filter(:new_sci_fi) { |movie| movie.period == :new && movie.genre.include?('Sci-Fi') }
      subject.define_filter(:newest_sci_fi, from: :new_sci_fi, arg: 2014)
      expect{subject.show(newest_sci_fi: true, country: 'Australia')}
      .to output(/^«Now showing: .* \(20[1-9][4-9]; .*Sci-Fi.*; Australia\) \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
      .and change(subject, :balance).by(Money.new(-500, 'USD'))
    end

    it 'When a movie is displayed on a personal filter based on a personal filter with a default filter and with block' do
      subject.account(500)
      subject.define_filter(:new_sci_fi) { |movie| movie.period == :new && movie.genre.include?('Sci-Fi') }
      subject.define_filter(:newest_sci_fi, from: :new_sci_fi, arg: 2014)
      expect{subject.show(new_sci_fi: true, country: 'Australia') { |movie| movie.title.include?('Mad Max: Fury Road') && movie.genre.include?('Adventure') && movie.year == 2015} }
      .to output(/^«Now showing: .* \(20[1-9][4-9]; .*Sci-Fi.*; Australia\) \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
      .and change(subject, :balance).by(Money.new(-500, 'USD'))
    end
  end
end
