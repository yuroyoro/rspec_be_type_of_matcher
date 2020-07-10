
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "version"

Gem::Specification.new do |spec|
  spec.name          = "rspec_be_type_of_matcher"
  spec.version       = BeTypeOfMatcher::VERSION
  spec.authors       = ["Tomohito Ozaki"]
  spec.email         = ["ozaki@yuroyoro.com"]

  spec.summary       = %q{Rspec matchers for strucural type assertion.}
  spec.description   = %q{Rspec matchers for strucural type assertion. Compare values of array to have all expeted_type, hash's key and value are expeted type}
  spec.homepage      = "https://github.com/yuroyoro/rspec_be_type_of_matcher"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "pry-byebug"
end
