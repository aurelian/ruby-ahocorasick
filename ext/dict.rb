#!/usr/bin/env ruby

require 'ahocorasick.so'

k= AhoCorasick::KeywordTree.from_file "../__tbr/en.all"

results= k.search(File.read("../__tbr/news.txt"))

results.each do | r |
  puts r[:value]
end

puts k.size
puts results.size
