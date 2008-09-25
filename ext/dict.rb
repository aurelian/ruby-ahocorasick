#!/usr/bin/env ruby

require 'ahocorasick.bundle'

k= AhoCorasick::KeywordTree.from_file "../__tbr/en.all"

puts k.size

results= k.search(File.read("gutenberg/melville-moby_dick.txt"))

puts results.size

