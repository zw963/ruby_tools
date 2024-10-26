# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'enumerable_statistics/version'

Gem::Specification.new do |spec|
  spec.name          = "enumerable-statistics"
  spec.version       = [
                         EnumerableStatistics::Version::MAJOR,
                         EnumerableStatistics::Version::MINOR,
                         EnumerableStatistics::Version::MICRO,
                         EnumerableStatistics::Version::TAG
                       ].compact.join('.')
  spec.authors       = ["Kenta Murata"]
  spec.email         = ["mrkn@mrkn.jp"]

  spec.summary       = %q{Statistics features for Enumerable}
  spec.description   = %q{This library provides statistics features for Enumerable}
  spec.homepage      = "https://github.com/mrkn/enumerable-statistics"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["ext", "lib"]
  spec.extensions    = Dir['ext/**/extconf.rb']

  spec.required_ruby_version = '>= 2.4'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rake-compiler", ">= 0.9.8"
  spec.add_development_dependency "rspec", ">= 3.4"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "fuubar"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "benchmark-driver"
end
