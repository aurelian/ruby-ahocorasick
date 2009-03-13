#!/usr/bin/env ruby

%w(../lib ../ext).each do |path|
  $LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), path)))
end

require "ahocorasick"
include AhoCorasick

# "smart" word filter.
class  WordFilter < ResultFilter

  #
  # separators: a list of int. representaion of a char (44-> ,) to indicate a word boundry
  #
  # pass a list of separators to redefine default ones:
  #
  # 32 -> space
  # 44 -> ,
  # 59 -> ;
  # 41 -> )
  # 34 -> "
  # 39 -> '
  #
  def initialize(separators= [])
    @separators= ([32, 44, 59, 41, 34, 39] + separators).uniq
    @separators.push(nil)
  end

  # check if it's valid
  def valid?(result, remain)
    @separators.include?(remain[result[:ends_at]-result[:starts_at]])
  end
end

t= Time.now
k= KeywordTree.from_file(File.dirname(__FILE__) + "/../spec/data/en.words")
t1= Time.now
puts "==> %d words added in %s seconds" % [k.size, (t1-t)]

k.filter= WordFilter.new

query = File.read( File.dirname(__FILE__) + "/../spec/data/news.txt" )
results= k.search query
puts "==> took %s seconds to find %d results in a streem with %d charachters" % \
  [(Time.now-t1), results.size, query.size]

puts "==> 20 results"
results[0..20].each do | r |
   puts "-- #{query[r[:starts_at]].chr}..#{query[r[:ends_at]-1].chr} => #{r[:value]}"
end


#
# some results:
#
# ==> took 366.236988 seconds to find 102601 results in a streem with 1242990 charachters
#
#

