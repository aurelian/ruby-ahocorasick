
require 'ahocorasick/native'

module AhoCorasick
  VERSION='0.6.2'
  
  class KeywordTree

    #
    # Loads the contents of file into the KeywordTree
    #
    #     k= AhoCorasick::KeywordTree.new
    #     k.from_file "dictionary.txt"
    #
    #
    def from_file file
      File.read(file).each { | string | self.add_string string }
      self
    end

    #
    # Creates a new KeywordTree and loads the dictionary from a file
    # 
    #    % cat dict0.txt
    #    foo
    #    bar
    #    base
    #     
    #    k= AhoCorasick::KeywordTree.from_file "dict0.txt"
    #    k.find_all("basement").size # => 1
    #
    def self.from_file filename
      self._from_file filename
    end
  end
end

