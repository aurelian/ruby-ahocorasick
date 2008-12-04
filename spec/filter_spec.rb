%w(../lib ../ext).each do |path|
  $LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), path)))
end

require 'ahocorasick'
include AhoCorasick

# mock objects :)

class Foo < ResultFilter
end

class DiscriminatorFilter < ResultFilter

  def valid?(result, remain)
    result[:value] == "foo"
  end

end

class PlayWithRemain < ResultFilter

  def valid?(result, remain)
    remain= "gg"
    true
  end

end

describe ResultFilter do

  it "should raise TypeError when the filter is not a ResultFilter" do
    k= KeywordTree.new
    lambda{k.filter= String.new}.should raise_error(TypeError)
  end

  it "should raise NotImplementedError when the filter is not implementing valid?" do
    k= KeywordTree.new
    k.filter= Foo.new
    lambda{k.filter.valid?("qq", {})}.should raise_error(NotImplementedError)
  end

  it "should filter the results" do
    k= KeywordTree.new
    k.add_string "foo"
    k.add_string "bar"
    k.filter= DiscriminatorFilter.new
    results= k.find_all("foo is not bar!")
    results.size.should == 1
    results[0][:value].should == "foo"
  end

  it "should not crash ruby" do
    k= KeywordTree.new
    k.add_string "foo"
    k.add_string "bar"
    k.filter= PlayWithRemain.new
    results= k.find_all("foo is not bar!")
    results.size.should == 2
  end

end

