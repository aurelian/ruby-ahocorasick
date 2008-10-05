require 'ext/ahocorasick'

include AhoCorasick

describe KeywordTree do

  describe "How to create a new KeywordTree" do
    it "should create a new KeywordTree" do
      KeywordTree.new.class.should == KeywordTree
    end
    it "should create a new KeywordTree" do
      KeywordTree.from_file( File.dirname(__FILE__) + "/data/dict0.txt").class.should == KeywordTree
    end
  end

  describe "How to search" do

    before(:each) do
      @kwt= KeywordTree.new
    end

    # XXX: is this usefull?
    after(:each) do
      @kwt= nil
    end
    it "find_all should return an array" do
      @kwt << "foo"
      @kwt.find_all("foo").class.should == Array
    end

    it "the array should contain hashes" do
      @kwt << "bar"
      @kwt << "foo"
      @kwt.find_all("foo")[0].class.should == Hash
    end
    
    it "should return empty array if no results" do
      @kwt.find_all("1a4a").should == []
    end

    it "each hash should have the required symbols values" do
      @kwt << "bar"
      @kwt << "foo"
      @kwt.find_all("foo").each do | r |
        r[:id].class.should == Fixnum
        r[:starts_at].class.should == Fixnum
        r[:ends_at].class.should == Fixnum
        r[:value].should == "foo"
      end
    end

    it "should match position" do
      #        0123
      #        |  |
      @kwt << "data"
      q= "data moved"
      @kwt.find_all(q).each do | result |
        result[:starts_at].should == 0
        result[:ends_at].should   == 4
      end
    end

    it "should match position with unicode" do
      #        012345689
      #        |       |
      @kwt << "bucurești"
      #   01234567890123456789023
      #                 |       |
      q= "data moved to bucurești"
      @kwt.find_all(q).each do | result |
        result[:starts_at].should == 14
        result[:ends_at].should   == 24
      end
    end

    it "more unicode" do
      @kwt << "expected"
      #    012345678901234578901234567890
      q = "moved to bucurești as expected"
      @kwt.find_all(q).each do | r |
        r[:starts_at].should == 23
        r[:ends_at].should   == q.size
        (r[:ends_at]-r[:starts_at]).should == r[:value].size
      end
    end
    
    it "even more unicode" do
      @kwt << "șșt"
      #                      0124789
      result= @kwt.find_all("mușștar").first
      result[:starts_at].should == 2
      result[:ends_at].should == result[:starts_at] + "șșt".size
    end

    it "checks for result length" do
      @kwt << "foo"
      result= @kwt.find_all("foo").first
      #          4                 0
      (result[:ends_at]-result[:starts_at]).should == result[:value].size
      "foo"[result[:ends_at]].should == nil
      "foo"[result[:ends_at]-1].chr.should == "o"
    end

  end

  describe "Context Match vs. Exact Word Match" do

    before(:each) do 
      @kwt= KeywordTree.from_file File.dirname(__FILE__) + "/data/dict0.txt"
    end

    it "should match on context" do
      @kwt.find_all("I've moved the data to a new database").size.should == 4
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
      kwt.add_string("foo", 1990).should == 1990
      kwt.add_string("bar").should == 1991
      kwt.size.should == 3
    end

    it "should return the id" do
      kwt= KeywordTree.new
      kwt.add_string("foo").should == 1
      kwt.add_string("bar", 2008).should == 2008
      kwt.add_string("kwt").should == 2009
    end

    it "should add strings from file and manually" do
      kwt= KeywordTree.from_file File.dirname(__FILE__) + "/data/dict0.txt"
      kwt << "foo"
      kwt.size.should == File.readlines( File.dirname(__FILE__) + "/data/dict0.txt" ).size + 1
    end

    it "should raise an error when adding new strings after the tree is frozen" do
      kwt= KeywordTree.from_file File.dirname(__FILE__) + "/data/dict0.txt"
      kwt.make
      lambda{kwt << "foo"}.should raise_error(RuntimeError)
    end

    it "should work to add entries on the tree after a search" do
      kwt= KeywordTree.from_file File.dirname(__FILE__) + "/data/dict0.txt"
      kwt.find_all("foo-bar not found")
      kwt.add_string("not found")
      kwt.find_all("foo-bar not found").size.should == 1
    end

  end

  describe "Benchmarks. Loading from a file" do

    it "should be fast to load a bunch of english words" do
      start= Time.now
      k= KeywordTree.from_file File.dirname(__FILE__) + "/data/en.words"
      puts "\n%d words loaded in %s seconds" % [k.size, (Time.now - start)]
      (Time.now-start).should < 0.2
    end

    it "should be fast to find" do
      start= Time.now
      k= KeywordTree.from_file File.dirname(__FILE__) + "/data/en.words"
      load_time= Time.now
      results= k.find_all( File.read( File.dirname(__FILE__) + "/data/melville-moby_dick.txt" ) )
      puts "\n%d words re-loaded in %s seconds.\nGot %d results in %s seconds" % [k.size, (load_time - start), results.size, (Time.now-load_time)]
      (Time.now-load_time).should < 1.3
    end
  end


end
