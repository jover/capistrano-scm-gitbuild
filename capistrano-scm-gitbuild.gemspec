# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/gitbuild/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-scm-gitbuild"
  spec.version       = Capistrano::Gitbuild::VERSION
  spec.authors       = ["Jochen Verdeyen"]
  spec.email         = ["jochenverdeyen@gmail.com"]

  spec.summary       = %q{GitBuild strategy for Capistrano 3}
  spec.description   = %q{Capistrano 3 build and copy strategy for git (checkout branch, apply build steps and deploy to server)}
  spec.homepage      = "https://github.com/jover/capistrano-scm-gitbuild"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'capistrano', '~> 3.0'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
