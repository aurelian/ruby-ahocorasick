#!/usr/bin/env ruby

require './ahocorasick'

k= AhoCorasick::KeywordTree.from_file "../__tbr/en.all"

query = File.read("../__tbr/news.txt")

results= k.search query

results.each do | r |
  puts query[r[:starts_at]].chr + ".." + query[r[:ends_at]].chr + " => " + r[:value]
end

# puts k.size
# puts results.size

