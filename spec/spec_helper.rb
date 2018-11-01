require 'rspec'
require 'rspec/its'
require 'csv'
require 'date'
require 'money'
require_relative '../lib/cash_box'
require_relative '../lib/movie_collection'
require_relative '../lib/movie'
require_relative '../lib/parser.rb'
require_relative '../lib/collection_renderer.rb'


RSpec::Matchers.define :be_sorted_by do |expected|
  match do |actual|
    actual == actual.sort_by(&expected)
  end
end
