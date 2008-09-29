#
# $Id: Rakefile 21 2008-04-30 10:57:37Z aurelian $
#

require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'spec/rake/spectask'


# rm_rf 'Makefile'

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

spec = Gem::Specification.new do | s |
  s.name = 'ruby-ahocorasick'
  s.version = '0.1.2'
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

pt = Rake::GemPackageTask.new(spec) do |p|
  p.need_tar = true
  p.need_zip = true
end

task :default do
  puts "Ok"
end

desc "Run rspec"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ["-c"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end


