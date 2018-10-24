class CollectionRenderer
  class RenderedMovie < OpenStruct
    def genre
      super.join(', ')
    end

    def actors
      super.join(', ')
    end
  end

  def initialize(collection)
    data = YAML.load_file('../views/data.yml')
    res = collection.map { |movie| CollectionRenderer::RenderedMovie.new(data[movie.imdb_id].merge(movie.to_h)) }
    @render = Haml::Engine.new(File.read('../views/netflix.html.haml')).render(res)
  end

  def write(path)
    File.write(path, @render)
  end
end
