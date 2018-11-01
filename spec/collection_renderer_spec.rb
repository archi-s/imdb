require_relative 'spec_helper'

describe CollectionRenderer do
  let(:renderer) { described_class.new(Imdb::MovieCollection.new('test/movies_spec.txt')) }
  let(:renderer_write) { renderer.write('test/netflix.html') }

  describe 'check_renderer' do
    it '#renderer' do
      expect( renderer ).to be_a CollectionRenderer
    end

    it '#write' do
      expect( renderer_write ).to be_a Fixnum
      expect( File.exists?('test/netflix.html') ).to be_truthy
      expect( File.read('test/netflix.html').include?('<td>Крестный отец</td>') ).to be_truthy
    end
  end
end
