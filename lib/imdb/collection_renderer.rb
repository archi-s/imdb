module Imdb
  class CollectionRenderer
    class RenderedMovie < OpenStruct
      %i[genre actors].each { |field| define_method(field) { super().join(', ') } }
    end

    def initialize(collection)
      data = YAML.load_file(Imdb::DATA_FILE_PATH)
      res = collection.map do |movie|
        RenderedMovie.new(data[movie.imdb_id].merge(movie.to_h))
      end
      @render = Haml::Engine.new(File.read(Imdb::NETFLIX_HAML_PATH)).render(res)
    end

    def write(path)
      File.write(path, @render)
    end
  end
end
