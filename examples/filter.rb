#!/usr/bin/env ruby

%w(../lib ../ext).each do |path|
  $LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), path)))
end

require "ahocorasick"

include AhoCorasick

# some fake classes.

# an Object.
class Foo;end;

# a ResultFilter.
class Bar < ResultFilter
end

# another one, but with implementation.
class  Baz < ResultFilter

  # note that it returns false. always
  def valid?(result, remain)
    puts "==> result: #{result.inspect} [#{result.class.name}]"
    puts "==> remain: #{remain} [#{remain.class.name}]"
    false
  end
end

k = KeywordTree.new
k.filter= Bar.new

puts "==> is valid? defined got #{k.filter.respond_to?("valid?")}"

begin
  k.filter.valid?("ss", {:foo=>"bar"})
rescue NotImplementedError => error
  puts "==> call valid? got #{error}"
end

begin
  k.filter= Foo.new
rescue TypeError => error
  puts "==> wrong interface? got #{error}"
end

k.add_string "foo"
k.add_string "bar"
k.filter= Baz.new

results= k.find_all("foo is not bar")
puts "==> should have 0 results? #{results.size==0}"

