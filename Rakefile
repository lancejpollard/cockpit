require 'rake'
require "rake/rdoctask"
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name              = "cockpit"
  s.authors           = ["Lance Pollard"]
  s.version           = "0.2.0"
  s.summary           = "Super DRY Configuration Management for Ruby, Rails, and Sinatra Apps.  With Pluggable NoSQL/SQL backends using Moneta"
  s.homepage          = "http://github.com/viatropos/cockpit"
  s.email             = "lancejpollard@gmail.com"
  s.description       = "Super DRY Configuration for Ruby, Rails, and Sinatra Apps.  With Pluggable NoSQL/SQL backends using Moneta"
  s.has_rdoc          = false
  s.rubyforge_project = "cockpit"
  s.platform          = Gem::Platform::RUBY
  s.files             = %w(README.markdown MIT-LICENSE.markdown) + Dir["{lib}/**/*"]
  s.require_path      = "lib"
  s.add_dependency("defined-by")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec    = spec
  pkg.package_dir = "pkg"
end

desc 'run unit tests'
task :test do
  Dir["test/**/*"].each do |file|
    next unless File.basename(file) =~ /test_/
    next unless File.extname(file) == ".rb"
    system "ruby #{file}"
  end
end

desc "Create .gemspec file (useful for github)"
task :gemspec do
  File.open("pkg/#{spec.name}.gemspec", "w") do |f|
    f.puts spec.to_ruby
  end
end

desc "Build the gem into the current directory"
task :gem => :gemspec do
  `gem build pkg/#{spec.name}.gemspec`
end

desc "Publish gem to rubygems"
task :publish => [:package] do
  %x[gem push pkg/#{spec.name}-#{spec.version}.gem]
end

desc "Print a list of the files to be put into the gem"
task :manifest do
  File.open("Manifest", "w") do |f|
    spec.files.each do |file|
      f.puts file
    end
  end
end

desc "Install the gem locally"
task :install => [:package] do
  File.mkdir("pkg") unless File.exists?("pkg")
  command = "gem install pkg/#{spec.name}-#{spec.version} --no-ri --no-rdoc"
  command = "sudo #{command}" if ENV["SUDO"] == true
  sh %{#{command}}
end

desc "Generate the rdoc"
Rake::RDocTask.new do |rdoc|
  files = ["README.markdown", "lib/**/*.rb"]
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.markdown"
  rdoc.title = spec.summary
end

task :yank do
  `gem yank #{spec.name} -v #{spec.version}`
end