GEM_NAME= 'ruby-ahocorasick'
GEM_VERSION= '0.6.2'

PKG_FILES = [
  'ext/ahocorasick/extconf.rb',
  'ext/ahocorasick/ruby-ahocorasick.c',
  'ext/ahocorasick/ac.h',
  'ext/ahocorasick/ac.c',
  'lib/ahocorasick.rb',
  'examples/dict.rb',
  'examples/test.rb',
  'examples/elev.rb',
  'examples/sample.c',
  'spec/ahocorasick_spec.rb',
  #'spec/data/en.words.tgz',
  #'spec/data/melville-moby_dick.txt.tgz',
  'MIT-LICENSE',
  'README.textile'
]

GEMSPEC = Gem::Specification.new do | s |
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.summary = "Aho-Corasick alghorithm implementation to Ruby using Strmat lib."
  s.description = <<-EOF
    Expose Aho-Corasick implementation from Strmat to Ruby.
  EOF

  s.files = PKG_FILES
  s.extensions << "ext/ahocorasick/extconf.rb"
  s.has_rdoc = true
  s.rdoc_options << '--title' <<  'Ruby-AhoCorasick' << 
    '--inline-source' << 'ext/ahocorasick/ruby-ahocorasick.c' << 'README.textile' << '--main' << 'README.textile'
  s.author = "Aurelian Oancea"
  s.email = "oancea at gmail dot com"
  s.homepage = "http://www.locknet.ro"
  s.rubyforge_project = "ruby-ahocorasick"
end

