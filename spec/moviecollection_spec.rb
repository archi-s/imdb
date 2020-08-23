require_relative 'spec_helper'

describe Imdb::MovieCollection do
  subject(:collection) { described_class.new('./data/movies.txt') }

  it "should return array with 250 items of movie class" do
    expect(collection.all).to be_a_kind_of(Array) & all( be_a_kind_of(Imdb::Movie) ) & satisfy { |v| v.size == 250 }
  end

  it "should return a hash with the number of films sorted by release month" do
    expect(collection.stat_by_month).to be_a_kind_of(Hash) & all(satisfy { |k, v| k.is_a?(String) && v.is_a?(Fixnum) })
  end

  describe '#sort_by' do
    subject { collection.sort_by(criteria) }

    context 'when filed not exist' do
      let(:criteria) { :_director }
      it { expect { subject }.to raise_error(Imdb::MovieCollection::ParamsNotExist, 'Params _director not exist') }
    end

    Imdb::Movie::KEYS.each do |field|
      context "when #{field}" do
        let(:criteria) { field }
        its(:count) { should eq 250 }
        it { is_expected.to be_an(Array) & all( be_a_kind_of(Imdb::Movie) ) }
        it { is_expected.to be_sorted_by(field) }
      end
    end
  end

  describe '#stats' do
    subject { collection.stats(criteria) }

    context 'when filed not exist' do
      let(:criteria) { :_director }
      it { expect { subject }.to raise_error(Imdb::MovieCollection::ParamsNotExist, 'Params _director not exist') }
    end

    shared_examples 'stats' do
      it { is_expected.to be_an(Hash) }
      its(:values) { are_expected.to all be_a(Fixnum) }
    end

    Imdb::Movie::KEYS[0..9].each do |field|
      context "when #{field}" do
        let(:criteria) { field }
        it_should_behave_like 'stats'
      end
    end
  end

  describe '#filter' do
    subject { collection.filter(criteria) }

    context 'when filed not exist' do
      let(:criteria) { { _director: "James Cameron" } }
      it { expect { subject }.to raise_error(Imdb::MovieCollection::ParamsNotExist, 'Params _director not exist') }
    end

    context 'when director' do
      let(:criteria) { { director: "James Cameron" } }
      it { is_expected.to all have_attributes(director: 'James Cameron') }
    end

    context 'when year' do
      let(:criteria) { { year: 1940..2000 } }
      it { is_expected.to all have_attributes(year: 1940..2000) }
    end

    context 'when title' do
      let(:criteria) { { title: /ermi/i } }
      it { is_expected.to all have_attributes(title: /ermi/i) }
    end

    context 'when country' do
      let(:criteria) { { country: 'USA' } }
      it { is_expected.to all have_attributes(country: 'USA') }
    end

    context 'when year' do
      let(:criteria) { { year: 1984 } }
      it { is_expected.to all have_attributes(year: 1984) }
    end

    context 'when genre' do
      let(:criteria) { { genre: "Action" } }
      it { is_expected.to all have_attributes(genre: include("Action")) }
    end

    context 'when duration' do
      let(:criteria) { { duration: /\d{3}/ } }
      it { is_expected.to all have_attributes(duration: /\d{3}/) }
    end

    context 'when rating' do
      let(:criteria) { { rating: 8.5...9.2 } }
      it { is_expected.to all have_attributes(rating: 8.5...9.2) }
    end

    context 'when actors' do
      let(:criteria) { { actors: "James Cameron" } }
      it { is_expected.to all have_attributes(actors: include("James Cameron")) }
    end

    context 'when all filters' do
      let(:criteria) { { actors: "James Cameron", rating: 8.5...9.2, duration: /\d{3}/,
      genre: "Action", country: 'USA', title: /ermi/i, year: 1940..2000, director: "James Cameron"  } }
      it { is_expected.to all have_attributes(actors: include("James Cameron"), rating: 8.5...9.2, duration: /\d{3}/,
        genre: "Action", country: 'USA', title: /ermi/i, year: 1940..2000, director: "James Cameron" ) }
    end
  end

  describe '#genre_exist?' do
    subject { collection.genre_exist?(criteria) }

    context "when genre exist" do
      let(:criteria) { 'Action' }
      it { is_expected.to be_truthy }
    end

    context "when genre not exist" do
      let(:criteria) { 'Not exist genre' }
      it { is_expected.to be_falsey }
    end
  end

  describe 'Method chain' do
    it 'Testing by all keys' do
      Imdb::Movie::KEYS[0..9].map do |field|
        expect(subject.send(field)).to be_a_kind_of(Imdb::MethodChain)
      end
    end

    it 'Testing by all genres' do
      subject.all.flat_map(&:genre).uniq.each do |genre|
        expect(subject.genre.send(genre)).to all have_attributes(genre: include(/#{genre}/i))
      end
    end

    it 'Testing by all countries' do
      subject.all.map(&:country).uniq.each do |country|
        expect(subject.country.send(country)).to all have_attributes(country: include(country))
      end
    end
  end
end


