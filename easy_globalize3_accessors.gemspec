# -*- encoding: utf-8 -*-
require File.expand_path("../lib/easy_globalize3_accessors/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "easy_globalize3_accessors"
  s.version     = EasyGlobalize3Accessors::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tomasz Stachewicz", "Wojciech Pietrzak", "Steve Verlinden", "Robert Pankowecki"]
  s.email       = ["tomekrs@o2.pl", "steve.verlinden@gmail.com", "robert.pankowecki@gmail.com", "rpa@gavdi.com"]
  s.homepage    = "http://rubygems.org/gems/easy_globalize3_accessors"
  s.summary     = "Define methods for accessing translated attributes"
  s.description = "Define methods for accessing translated attributes"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "easy_globalize3_accessors"

  s.add_dependency "globalize3", "~> 0.3.0"

  s.add_development_dependency "bundler", "~> 1.0.15"
  s.add_development_dependency "rake", "~> 0.9.2"
  s.add_development_dependency "sqlite3"


  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
