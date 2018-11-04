require_relative 'config/spec_helper'

describe Imdb::CollectionRenderer do
  let(:renderer) { described_class.new(Imdb::MovieCollection.new('data/movies_spec.txt')) }
  let(:save_html) { renderer.write('data/netflix.html') }
  let(:remove_html) { File.delete('data/netflix.html') }

  before { save_html }
  after { remove_html }

  describe 'check_renderer' do
    it { expect( Nokogiri::HTML(File.read('data/netflix.html')).css('td').text ).to include("Крестный отец") }
  end
end

