require_relative 'spec_helper'

describe Parser do
  let(:parser) { described_class.new(Imdb::MovieCollection.new('test/movies_spec.txt')) }
  let(:fetch_movie) { parser.fetch_movie('tt0068646') }
  let(:parser_run) { parser.run }
  let(:parser_write) { parser.run.write('test/data.yml') }
  let(:file_read) { YAML.load_file('test/data.yml') }

  describe 'check_parser' do
    it '#fetch_movie' do
      expect( fetch_movie ).to be_a Hash
      expect( fetch_movie["tt0068646"][:ru_title] ).to eql "Крестный отец"
      expect( fetch_movie["tt0068646"][:poster] ).to match /.*.jpg$/i
      expect( fetch_movie["tt0068646"][:budget] ).to match /\d{1,10}/
    end

    it '#run' do
      expect( parser_run ).to be_a Parser
    end

    it '#write' do
      expect( parser_write ).to be_a Fixnum
    end

    it '#check_file_with_data' do
      expect( file_read ).to be_a(Hash)
      expect{ file_read.has_key?("tt0068646").to be_truthy }
      expect( file_read["tt0068646"].has_key?(:ru_title) ).to be_truthy
      expect( file_read.count ).to eq 3
    end
  end
end
