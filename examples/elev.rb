#!/usr/bin/env ruby

$kcode='UTF-8'

require File.dirname(__FILE__) + '/../ext/ahocorasick'

k= AhoCorasick::KeywordTree.new

k << "I've"
k << "data"
k << "base"
k << "database"

query= "I've moved my data to a database"

k.search query do | r |
  puts "-> [ " + r[:id].to_s + " ] " + r[:value] + " / " + query[r[:starts_at]].chr + ".." + query[r[:ends_at]-1].chr
end

