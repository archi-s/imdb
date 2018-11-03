require_relative 'spec_helper'

describe CollectionRenderer do
  let(:renderer) { described_class.new(Imdb::MovieCollection.new('test/movies_spec.txt')) }
  let(:save_html) { renderer.write('test/netflix.html') }
  let(:remove_html) { File.delete('test/netflix.html') }

  before { save_html }
  after { remove_html }

  describe 'check_renderer' do
    it { expect( Nokogiri::HTML(File.read('test/netflix.html')).css('td').text ).to include("Крестный отец") }
  end
end

