#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../ext/ahocorasick'

k= AhoCorasick::KeywordTree.new

puts k.size
k.add_string("foo");

puts k.size
k.add_string("bar", 1991);

puts k.size
k.add_string("fomz");

begin
  k.add_string("foo", -1);
rescue RuntimeError => err
  puts "[ok]==> got " + err.class.name + ": " + err.message
end

begin
  k.add_string("foo", "bar");
rescue RuntimeError => err
  puts "[ok]==> got " + err.class.name + ": " + err.message
end

k.add_string("timisoara", 22);

puts k.size
begin
  k.add_string("bucuresti", 22);
rescue RuntimeError => err
  puts "[ok]==> got " + err.class.name + ": " + err.message
end

k << "bacau"

k.search 'am fost la bacau' do | result |
  puts result.inspect
end

k.search( 'din foo in foo' ).each do | q |
  puts q.inspect
end

