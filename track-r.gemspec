# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{track-r}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jose Felix Gomez"]
  s.date = %q{2009-09-15}
  s.description = %q{track-r is a library that provides wrapper classes and methods for accessing PivotalTracker's public API.}
  s.email = %q{jfgomez86@gmail.com}
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    ".gitignore",
     "README.textile",
     "Rakefile",
     "VERSION",
     "config/config.yml",
     "config/environment.rb",
     "config/gems.yml",
     "lib/track-r.rb",
     "lib/track-r/api_connector/connection.rb",
     "lib/track-r/api_connector/request.rb",
     "lib/track-r/api_connector/response.rb",
     "lib/track-r/iteration.rb",
     "lib/track-r/project.bak.rb",
     "lib/track-r/project.rb",
     "lib/track-r/story.rb",
     "lib/track-r/token.rb",
     "lib/track-r/tracker.rb",
     "pkg/track-r-1.0.0.gem",
     "test/test_config.yml.example",
     "test/test_helper.rb",
     "test/unit/project_test.rb",
     "test/unit/story_test.rb",
     "test/unit/token_test.rb",
     "test/unit/tracker_test.rb",
     "vendor/install-gems/install-gems.rb"
  ]
  s.homepage = %q{http://github.com/jfgomez86/Track-R}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A wrapper library for pivotal tracker's API}
  s.test_files = [
    "test/test_helper.rb",
     "test/unit/project_test.rb",
     "test/unit/story_test.rb",
     "test/unit/token_test.rb",
     "test/unit/tracker_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
