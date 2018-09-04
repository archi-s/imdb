require_relative 'spec_helper'

describe Imdb::MovieCollection do
  subject(:collection) { described_class.new('../lib/movies.txt') }

    describe '#genres' do
      subject { collection.genres }

      context "genres" do
        it { is_expected.to be_an(Array) }
      end
    end

    describe '#sort_by' do
      subject { collection.sort_by(criteria) }

      context 'when parametr not exist' do
        let(:criteria) { :director1 }
        it { expect { subject }.to raise_error(Imdb::MovieCollection::ParametrNotExist) }
      end

      Imdb::MovieCollection::KEYS.each do |field|
        context "when #{field}" do
          let(:criteria) { field }
          its(:count) { should eq 250 }
          it { is_expected.to be_an(Array).and all( be_an(Imdb::Movie) ) }
          it { is_expected.to be_sorted_by(field) }
        end
      end

    end

    describe '#top_five_movies_by_duration' do
      subject { collection.top_five_movies_by_duration }

      context "top five movies by duration" do
        it { is_expected.to be_an(Array) }
      end
    end

    describe '#ten_comedies' do
      subject { collection.ten_comedies }

      context "ten comedies" do
        it { is_expected.to be_an(Array) }
      end
    end

    describe '#directors' do
      subject { collection.directors }

      context "directors" do
        it { is_expected.to be_an(Array) }
      end
    end

    describe '#not_country_movies' do
      subject { collection.not_country_movies(criteria) }

      context "not country movies" do
        let(:criteria) { 'USA' }
        it { is_expected.to be_an(Fixnum) }
      end
    end

    describe '#stat_by_month' do
      subject { collection.stat_by_month }

      context "stat by month" do
        it { is_expected.to be_an(Array) }
      end
    end

    describe '#filter' do
      subject { collection.filter(criteria) }

      context 'when filed not exist' do
        let(:criteria) { { director1: "James Cameron" } }
        it { expect { subject }.to raise_error(Imdb::MovieCollection::ParametrNotExist) }
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

      context 'when release' do
        let(:criteria) { { release: 1984 } }
        it { is_expected.to all have_attributes(release: 1984) }
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
        genre: "Action", release: 1984, country: 'USA', title: /ermi/i, year: 1940..2000, director: "James Cameron"  } }
        it { is_expected.to all have_attributes(actors: include("James Cameron"), rating: 8.5...9.2, duration: /\d{3}/,
          genre: "Action", release: 1984, country: 'USA', title: /ermi/i, year: 1940..2000, director: "James Cameron" ) }
      end
    end

    describe '#stats' do
      subject { collection.stats(criteria) }

      context 'when filed not exist' do
        let(:criteria) { :director1 }
        it { expect { subject }.to raise_error(Imdb::MovieCollection::ParametrNotExist) }
      end

      shared_examples 'stats' do
        it { is_expected.to be_an(Hash) }
        its(:values) { are_expected.to all be_a(Fixnum) }
      end

      Imdb::MovieCollection::KEYS.each do |field|
        context "when #{field}" do
          let(:criteria) { field }
          it_should_behave_like 'stats'
        end
      end
    end
end
