require "rake/clean"

task default: :test

desc "run all tests"
task :test do
  sh "rspec"
end

desc "build the gem"
task :build do
  sh "gem build"
end
CLOBBER.include "*.gem"

%w[patch minor major].each do |version|
  desc "bump #{version} version"
  task :"bump:#{version}" do
    sh "gem bump -v #{version} --tag"
  end
end

CLEAN.include "**/*.prg"
desc "builds all examples"
task :examples do
  Dir["examples/**/*.rb"].each do |f|
    Dir.chdir File.dirname f do
      ruby File.basename f
    end
  end
end
