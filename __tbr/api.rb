module AhoCorasick

  class Dictionary

    # loads a dictionary from a file,
    # each line is a dictionary entry
    # returns self
    def self.from_file( file )

    end

    # 
    def self.from_memcache( memcache_details )
    end

    # 
    def self.from_mysql( mysql_details )
    end

    # returns the size of this dictionary
    def size
    end

  end

  class SearchResult
    
    attr_reader :id, :length, :value

    def initialize(id, length, value)
      self.id= id
      self.length= length
      self.value= value
    end

    def to_s
      value
    end

  end

  class KeywordTree

    def initialize(dictionary= nil)
    end

    # adds a string to dictionary
    # on a nil id, the system will generate one
    def add_string(string, id= nil)
    end
    
    # removes a string from dictionary
    def del_string(string)
    end

    # creates the Tree
    def make
    end

    # finds the first entry, 
    # returns item id
    def find_first(str)
      prepare_search
      search(str)
    end

    #
    # k= KeywordTree.new
    # k.add_string("foo", 1);
    # k.add_string("bar", 2);
    # k.make
    #
    # k.find_all("not that much left out of foo") do | result |
    #   puts result.to_s == result.value
    #   puts result.id
    #   puts result.length
    # end
    #
    def search(str) yield result
      __prepare_search
      results= []
      result = __do_search(str)
      yield result if block_given?
      results
    end

    private
      # initialize the search
      def __prepare_search
      end

      # do the search
      def __do_search str
      end

  end

end
