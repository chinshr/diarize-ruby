# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'diarize/version'

Gem::Specification.new do |spec|
  spec.name          = "diarize-ruby"
  spec.version       = Diarize::VERSION
  spec.date          = "2016-07-09"
  spec.authors       = ['Yves Raimond', 'Juergen Fesslmeier']
  spec.summary       = "Speaker Diarization for Ruby"
  spec.email         = ["jfesslmeier@gmail.com"]
  spec.homepage      = "https://github.com/chinshr/diarize-ruby"
  spec.description   = "A library for Ruby wrapping the LIUM Speaker Diarization and including a few extra tools"
  spec.has_rdoc      = false
  spec.license       = "GNU Affero General Public License version 3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'bin'
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_development_dependency "mocha", "~> 1.1"
  spec.add_development_dependency "webmock", "~> 2.1"
  spec.add_development_dependency "byebug", "~> 9.0"

  spec.add_dependency "rjb", "~> 1.5"
  spec.add_dependency "to-rdf", "~> 0"
  spec.add_dependency "jblas-ruby", "~> 1.1"
end
