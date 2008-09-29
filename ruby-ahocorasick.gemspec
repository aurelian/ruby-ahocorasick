
PKG_FILES = FileList[
  'ext/extconf.rb',
  'ext/ruby-ahocorasick.c',
  'ext/ac.h',
  'ext/ac.c',
  #'spec/ahocorasick_spec.rb',
  #'spec/data/en.words.tgz',
  #'spec/data/melville-moby_dick.txt.tgz',
  '[A-Z]*',
]

PKG_FILES.exclude('ext/*.o')
PKG_FILES.exclude('ext/*.bundle')
PKG_FILES.exclude('ext/*.a')
PKG_FILES.exclude('ext/*.so')
PKG_FILES.exclude('ext/Makefile')
PKG_FILES.exclude('Rakefile')

GEM_NAME= 'ruby-ahocorasick'
GEM_VERSION= '0.1.4'

GEMSPEC = Gem::Specification.new do | s |
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.summary = "Aho-Corasick alghorithm implementation to ruby using Strmat lib."
  s.description = <<-EOF
    Expose Aho-Corasick implementation from Strmat to ruby.
  EOF

  s.files = PKG_FILES.to_a
  s.extensions << "ext/extconf.rb"
  s.has_rdoc = true
  s.rdoc_options << '--title' <<  'Ruby-AhoCorasick' << 
    '--inline-source' << 'ext/ruby-ahocorasick.c' << 'README.textile' << '--main' << 'README.textile'
  s.author = "Aurelian Oancea"
  s.email = "aurelian@locknet.ro"
  s.homepage = "http://locknet.ro"
  s.rubyforge_project = "ruby-ahocorasick"
end

