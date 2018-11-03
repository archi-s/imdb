require_relative 'spec_helper'

describe Parser do
  let(:parser) { described_class.new(Imdb::MovieCollection.new('test/movies_spec.txt')) }

  describe 'check_parsing' do
    let(:file_write) { parser.run.write('test/data.yml') }
    let(:file_read) { YAML.load_file('test/data.yml') }
    let(:file_delete) { File.delete('test/data.yml') }

    before { file_write }
    after { file_delete }

    it '#check_file_with_data' do
      expect( file_read["tt0068646"] ).to include(ru_title: 'Крестный отец', poster: /\.jpg$/i, budget: '6000000')
      expect( file_read.count ).to eq 3
    end
  end

  # describe '#fetch_movie' do
  #   let(:movie_id_with_budget) { 'tt0068646' }
  #   let(:movie_id_without_budget) { 'tt0022100' }
  #   let(:non_existent_movie_id) { 'tt9999999' }

  #   context 'movie_id_with_budget' do
  #     subject { parser.fetch_movie(movie_id_with_budget) }
  #     it { is_expected.to include(ru_title: 'Крестный отец', poster: /\.jpg$/i, budget: '6000000') }
  #   end

  #   context 'movie_id_without_budget' do
  #     subject { parser.fetch_movie(movie_id_without_budget) }
  #     it { is_expected.to include(ru_title: 'М убийца', poster: /\.jpg$/i, budget: 'N/A') }
  #   end

  #   it 'non_existent_movie_id' do
  #     expect{ parser.fetch_movie(non_existent_movie_id) }.to raise_error(Parser::MovieNotFound, '404 Not Found')
  #   end
  # end
end
