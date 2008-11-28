#!/usr/bin/env ruby

%w(../lib ../ext).each do |path|
  $LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), path)))
end

require "ahocorasick"

k= AhoCorasick::KeywordTree.new

k << "I've"
k << "data"
k << "base"
k << "database"

query= "I've moved my data to a database"

k.search(query).each do | r |
  puts "-> [ " + r[:id].to_s + " ] " + r[:value] + " / " + query[r[:starts_at]].chr + ".." + query[r[:ends_at]-1].chr
end

