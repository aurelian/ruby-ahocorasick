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
    it "should return an array" do
      @kwt << "foo"
      @kwt.search("foo").class.should == Array
    end

    it "the array should contain hashes" do
      @kwt << "bar" << "foo"
      @kwt.search("foo")[0].class.should == Hash
    end
    
    # XXX: this is subject of ...talks
    # it "should return nil if block_given?" do
    #  @kwt.search("foo"){|r| r[:id]}.should == nil
    #end

    it "should return empty array if no results" do
      @kwt.search("1a4a").should == []
    end

    it "each hash should have the required symbols values" do
      @kwt << "bar" << "foo"
      @kwt.search("foo").each do | r |
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
      @kwt.search(q).each do | result |
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
      @kwt.search(q).each do | result |
        result[:starts_at].should == 14
        result[:ends_at].should   == 24
      end
    end

    it "more unicode" do
      @kwt << "expected"
      #    012345678901234578901234567890
      q = "moved to bucurești as expected"
      @kwt.search(q).each do | r |
        r[:starts_at].should == 23
        r[:ends_at].should   == q.size
        (r[:ends_at]-r[:starts_at]).should == r[:value].size
      end
    end

    it "checks for result length" do
      @kwt << "foo"
      result= @kwt.search("foo").first
      #          4                 0
      (result[:ends_at]-result[:starts_at]).should == result[:value].size
      "foo"[result[:ends_at]].should == nil
      "foo"[result[:ends_at]-1].chr.should == "o"
    end

  end

  describe "Context Match vs. Exact Word Match" do

    before(:each) do 
      # data, base, database
      @kwt= KeywordTree.from_file File.dirname(__FILE__) + "/data/dict0.txt"
    end

    it "should match on context" do
      @kwt.search("I've moved the data to a new database").size.should == 4
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
      kwt.size.should == 3
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
      results= k.search( File.read( File.dirname(__FILE__) + "/data/melville-moby_dick.txt" ) )
      puts "\n%d words re-loaded in %s seconds.\nGot %d results in %s seconds" % [k.size, (load_time - start), results.size, (Time.now-load_time)]
      (Time.now-load_time).should < 1.2
    end
  end


end
