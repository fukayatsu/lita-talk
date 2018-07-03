Gem::Specification.new do |spec|
  spec.name          = "lita-talk"
  spec.version       = "0.1.5"
  spec.authors       = ["fukayatsu"]
  spec.email         = ["fukayatsu@gmail.com"]
  spec.description   = "Talk with you if given message didn't match any other handlers."
  spec.summary       = "Talk with you if given message didn't match any other handlers."
  spec.homepage      = "https://github.com/fukayatsu/lita-talk"
  spec.license       = "MIT License"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", "~> 4.3"
  spec.add_runtime_dependency "faraday"
  spec.add_runtime_dependency 'faraday_middleware'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
