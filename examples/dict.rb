#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../ext/ahocorasick'

k= AhoCorasick::KeywordTree.from_file(File.dirname(__FILE__) + "/../spec/data/en.words")

query = File.read( File.dirname(__FILE__) + "/../spec/data/news.txt")

results= k.search query

results.each do | r |
  puts query[r[:starts_at]].chr + ".." + query[r[:ends_at]-1].chr + " => " + r[:value]
end

