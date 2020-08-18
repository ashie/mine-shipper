require File.expand_path('../lib/mine-shipper/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "mine-shipper"
  spec.version        = MineShipper::VERSION
  spec.authors       = ["Takuro Ashie"]
  spec.email         = ["ashie@clear-code.com"]
  spec.summary       = "Connect GitHub issues with Redmine"
  spec.description   = "Duplicate comments in GitHub issues to Redmine"
  spec.homepage      = "https://gitlab.com/clear-code/mine-shipper"
  spec.license       = "GPL-3.0-or-later"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("octokit", "~> 4.0")
  spec.add_runtime_dependency("dotenv", "~> 2.7")
  spec.add_development_dependency("rake", "~> 13.0")
  spec.add_development_dependency("test-unit", "~> 3.3")
  spec.add_development_dependency("test-unit-rr", "~> 1.0")
end
