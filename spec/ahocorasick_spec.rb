require 'ext/ahocorasick'

include AhoCorasick

describe KeywordTree do

  describe "How to create a new KeywordTree" do

    it "should create a new KeywordTree" do
      KeywordTree.new.class.should == AhoCorasick::KeywordTree
    end

    it "should create a new KeywordTree" do
      KeywordTree.from_file("__tbr/dict0.txt").class.should == AhoCorasick::KeywordTree
    end

  end

  describe "How to add strings" do

    it "should add 2 strings" do
      kwt= KeywordTree.new
      kwt.add_string "foo"
      kwt << "bar"
      kwt.size.should == 2
    end

    it "should add 2 strings with id" do
      kwt= KeywordTree.new
      kwt.add_string "foo", 1
      kwt.add_string "bar", 2
      kwt.size.should == 2
    end

    it "should rise an error when adding same id twice" do
      kwt= KeywordTree.new
      kwt.add_string "foo", 1
      lambda{kwt.add_string("bar", 1)}.should raise_error(RuntimeError)
    end

    it "should raise an error when not using id's > 0" do
      kwt= KeywordTree.new
      lambda{kwt.add_string("bar", -1)}.should raise_error(RuntimeError)
      lambda{kwt.add_string("bar", "a")}.should raise_error(RuntimeError)
      lambda{kwt.add_string("bar", 0)}.should raise_error(RuntimeError)
    end

    it "should work to add a random id" do
      kwt= KeywordTree.new
      kwt << "baz"
      kwt.add_string "foo", 1990
      kwt << "bar"
    end

  end

end
