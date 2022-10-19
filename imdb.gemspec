lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'imdb'
require 'stdlib'

Gem::Specification.new do |spec|
  spec.name          = 'Imdb'
  spec.version       = Imdb::VERSION
  spec.authors       = ['Arthur H.']
  spec.email         = ['']
  spec.description   = 'Gem for parsing movies from IMDB'
  spec.summary       = 'Top 250 movies'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)

  spec.bindir = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'dotenv', '2.5.0'
  spec.add_dependency 'haml', '5.0.4'
  spec.add_dependency 'money', '6.12.0'
  spec.add_dependency 'nokogiri', '1.13.9'
  spec.add_dependency 'ruby-progressbar', '1.10.0'
  spec.add_dependency 'slop', '4.6.2'
  spec.add_dependency 'virtus', '1.0.5'
  spec.add_dependency 'yard', '0.9.20'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its', '1.2.0'
end
