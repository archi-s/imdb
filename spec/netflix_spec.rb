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
    it 'When not enough money' do
      subject.pay(1)
      expect{subject.show(title: /ter/i)}.to raise_error(Imdb::Netflix::NotEnoughMoney)
    end

    it 'When showing movie' do
      subject.pay(10)
      expect{subject.show(title: 'Groundhog Day')}
      .to output(/^«Now showing: Groundhog Day \d{2}:\d{2}:\d{2} - \d{2}:\d{2}:\d{2}»/i).to_stdout
      .and change(subject, :balance).by(Money.new(-300, 'USD'))
    end

    it 'Film not found' do
      subject.pay(10)
      expect{subject.show(title: 'Groundhog Days')}.to raise_error(Imdb::Netflix::MoviesByPatternNotFound)
    end
  end

end
