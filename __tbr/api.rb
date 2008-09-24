module AhoCorasick

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

    # loads a dictionary from a file,
    # each line is a dictionary entry
    # returns self
    def self.new_from_file( file )
    end

    # TODO:
    def self.new_from_memcache( memcache_details )
    end

    # TODO:
    def self.new_from_mysql( mysql_details )

    end

    def initialize
    end

    # adds a string to dictionary
    # on a nil id, the system will generate one
    def add_string(string, id)
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
    def find_all(str) yield result
      prepare_search
      yield search(str) if block_given?
    end

    protected
      # initialize the search
      def prepare_search
      end

  end

end
