
require 'ahocorasick/native'

module AhoCorasick
  VERSION='0.6.1'
  
  class KeywordTree

    def from_file file
      File.read(file).each { | string | self.add_string string }
      self
    end

    def self.from_file filename
      self._from_file filename
    end
  end
end

