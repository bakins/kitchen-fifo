# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/fifo_version.rb'

Gem::Specification.new do |gem|
  gem.name          = "kitchen-fifo"
  gem.version       = Kitchen::Driver::FIFO_VERSION
  gem.authors       = ["Brian Akins"]
  gem.email         = ["brian@akins.org"]
  gem.description   = "Kitchen::Driver::FIFO - A Test Kitchen Driver for Project-FIFO"
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/bakins/kitchen-fifo/"
  gem.license       = "Apache 2.0"
  gem.files         = `git ls-files`.split($/)
  gem.executables   = []
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'test-kitchen', '~> 1.0.0.alpha.0'
  gem.add_dependency 'project-fifo-ruby'
end
