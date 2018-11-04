require 'rspec'
require 'rspec/its'
require_relative '../../lib/imdb.rb'


RSpec::Matchers.define :be_sorted_by do |expected|
  match do |actual|
    actual == actual.sort_by(&expected)
  end
end
