#!/usr/bin/env ruby
# require 'open-uri'
# require 'nokogiri'

# def parse_links
#   page = Nokogiri::HTML(open('https://www.imdb.com/chart/top'))
#   page.css('.titleColumn').each do |val|
#     link = "#{val.at_css('a')['href'].gsub(/\?.*/, '')}\n"
#     File.write('../bin/links.txt', link, mode: 'a')
#   end
# end

# def parse_movies
#   File.read('../bin/links.txt').each_line do |link|
#     link = "https://www.imdb.com#{link}".strip
#     page = Nokogiri::HTML(open(link))
#     line = line_formation(link, page)
#     File.write('../bin/movies.txt', line, mode: 'a')
#   end
# end

# def line_formation(link, page)
#   title = page.css('.originalTitle').text.gsub(' (original title)', '')
#   country = page.at('h4:contains("Country:")').parent.text.gsub(/Country:(.*)/, '\1').strip
#   release = Date.parse(page.at('h4:contains("Release Date:")').parent.text.gsub(/\n/, '')
#   .gsub(/.*:(.*)\(.*/, '\1').strip).strftime("%F")
#   year = release.gsub(/(\d{4}).*/, '\1').to_i
#   gerne = page.at('h4:contains("Genres:")').parent.text.gsub(/Genres:(.*)/, '\1').strip
#   duration = page.at('h4:contains("Runtime:")').parent.text.gsub(/Runtime:(.*)/, '\1').strip.to_i
#   rating = page.at('.rating').parent.text.to_f
#   director = page.at('h4:contains("Director:")').parent.text.gsub(/Director:(.*)/, '\1').strip
#   actors = page.at('h4:contains("Stars:")').parent.text.gsub(/\n/, '')
#   .gsub(/Stars:(.*)\|.*/, '\1').strip
#   [link,title,year,country,release,gerne,duration,rating,director,actors].join('|')
# end

# parse_links
# parse_movies
