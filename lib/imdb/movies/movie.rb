module Imdb
  class Movie
    include Virtus.model
    include MovieConstruct

    GenreNotFound = Class.new(Error)
    PeriodNotFound = Class.new(Error)

    KEYS = %i[link title year country release genre duration rating director actors]

    attr_reader(*KEYS.push(:collection))

    def self.create(movie)
      case movie[:year].to_i
      when -Float::INFINITY..1944
        AncientMovie.new(movie)
      when 1945..1967
        ClassicMovie.new(movie)
      when 1968..1999
        ModernMovie.new(movie)
      when 2000..Time.now.year
        NewMovie.new(movie)
      else
        raise PeriodNotFound, 'Period not found'
      end
    end

    def period
      self.class.to_s.gsub(/.*::(.*)Movie/, '\1').downcase.to_sym
    end

    def genre?(genre)
      if matches?(genre: genre)
        true
      elsif collection.genre_exist? genre
        false
      else
        raise GenreNotFound, "Genre #{genre} not found"
      end
    end

    def imdb_id
      link.split('/')[4]
    end

    def to_h
      KEYS.map { |var| [var, instance_variable_get("@#{var}")] }.to_h
    end

    def matches?(opts)
      opts.reduce(true) do |res, (filter_name, filter_value)|
        if filter_name =~ /^exclude_(.+)/
          exclude_filter_name = Regexp.last_match(1)
          res && !match_pattern?(exclude_filter_name, filter_value)
        else
          res && match_pattern?(filter_name, filter_value)
        end
      end
    end

    private

    def match_pattern?(filter_name, filter_value)
      value = send(filter_name)
      if value.is_a?(Array) && filter_value.is_a?(Array)
        filter_value.any? { |val| value.any? { |v| val === v } }
      elsif value.is_a?(Array)
        value.any? { |val| filter_value === val }
      else
        filter_value.is_a?(Array) ? filter_value.any? { |val| val === value } : filter_value === value
      end
    end

    def inspect
      "<#{self.class} #{title}; #{year}; #{genre}>"
    end
  end
end
