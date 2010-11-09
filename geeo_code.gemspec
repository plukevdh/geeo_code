# -*- encoding: utf-8 -*-
require File.expand_path("../lib/geeo_code/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "geeo_code"
  s.version     = GeeoCode::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Luke van der Hoeven"]
  s.email       = ["hungerandthirst@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/geeo_code"
  s.summary     = "Quick gem to do google geocoding based on the json/xml api (v3)."
  s.description = "This gem is has a simple, singular purpose to wrap itself warmly around google's 
    geocoding apis and give you back cleanly parsed hashes of the data. Maybe, one day, this will 
    send back Ruby objects rather than simple hashes, but this does the trick for now."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "geeo_code"

  s.add_development_dependency "bundler", ">= 1.0.3"

  s.add_dependency "yajl-ruby", "~> 0.7"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'

end
