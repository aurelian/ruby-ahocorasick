
require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

load File.join(File.dirname(__FILE__), 'ruby-ahocorasick.gemspec')

pt = Rake::GemPackageTask.new(GEMSPEC) do |p|
  p.need_tar = true
  p.need_zip = true
end

# Rake::GemPackageTask.new(GEMSPEC).define

task :install => [:package] do
  `gem install pkg/#{GEM_NAME}-#{GEM_VERSION}`
end


task :default do
  puts "Ok"
end

desc "Runs ruby extconf.rb"
task :extconf do
  `cd ext && ruby extconf.rb && cd ../`
end

desc "Makes the extension"
task :ext => :extconf do
  `cd ext/ && make && cd ../`
end

desc "Cleans the workspace"
task :clean do
  `rm -rf ext/*.o ext/*.so ext/Makefile ext/*.bundle`
end

desc "Run rspec"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ["-c"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end


