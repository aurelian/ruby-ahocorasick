#!/usr/bin/env ruby

require 'time'

require File.dirname(__FILE__) + '/../ext/ahocorasick'

t= Time.now

k= AhoCorasick::KeywordTree.from_file(File.dirname(__FILE__) + "/../spec/data/en.words")

t1= Time.now

puts "%d words added in %s seconds" % [k.size, (t1-t)]

query = File.read( File.dirname(__FILE__) + "/../spec/data/news.txt" )

results= k.search query

puts "took %s seconds to find %d results in a streem with %d charachters" % [(Time.now-t1), results.size, query.size]

exit
results.each do | r |
  puts query[r[:starts_at]].chr + ".." + query[r[:ends_at]-1].chr + " => " + r[:value]
end

