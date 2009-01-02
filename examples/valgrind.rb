# a simple script to execute under valgrind
require 'ext/ahocorasick/native.so'

(1..10).each{ | n | 
  k= AhoCorasick::KeywordTree._from_file("spec/data/dict0.txt") 
}

