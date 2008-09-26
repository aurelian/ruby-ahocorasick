#!/usr/bin/env ruby

$kcode='UTF-8'

require 'ahocorasick.so'

k= AhoCorasick::KeywordTree.from_file "../__tbr/en.all"

#k << "data"
#k << "base"
#k << "database"

k.search "I've moved my data to a database" do | r |
  puts r[:value] + "-> " + r[:length].to_s
end



