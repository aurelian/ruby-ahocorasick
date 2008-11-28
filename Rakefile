require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

load File.join(File.dirname(__FILE__), 'ruby-ahocorasick.gemspec')

pt = Rake::GemPackageTask.new(GEMSPEC) do |p|
  p.need_tar = true
  p.need_zip = true
end

task :install => [:package] do
  `gem install pkg/#{GEM_NAME}-#{GEM_VERSION}`
end

task :default do
  puts "Ok"
end

desc "Runs ruby extconf.rb"
task :extconf => :clean do
  Dir.chdir('ext/ahocorasick') do
    ruby "extconf.rb"
  end
end

desc "Makes the extension"
task :ext => :extconf do
  Dir.chdir('ext/ahocorasick') do
    sh "make"
  end
end

desc "Cleans the workspace"
task :clean do
  sh "rm -rf ext/ahocorasick/*.o ext/ahocorasick/*.so ext/ahocorasick/Makefile ext/ahocorasick/*.bundle"
end

desc "Run rspec"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ["-c"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

