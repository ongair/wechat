# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wechat/version'

Gem::Specification.new do |spec|
  spec.name          = "wechat"
  spec.version       = Wechat::VERSION
  spec.authors       = ["Trevor Kimenye"]
  spec.email         = ["kimenye@sprout.co.ke"]
  spec.summary       = %q{Simple gem to help you use WeChat.}
  spec.description   = %q{Simple gem to help you use WeChat.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "1.6.1"
  spec.add_dependency "redis-rack"
  spec.add_dependency "httparty"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "redis_test"
end
