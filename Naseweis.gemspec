# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'naseweis/version'

Gem::Specification.new do |spec|
  spec.name          = "Naseweis"
  spec.version       = Naseweis::VERSION
  spec.authors       = ["Daniel Schadt"]
  spec.email         = ["kingdread@gmx.de"]

  spec.summary       = "Gather lots of information based on questionnaire files."
  spec.description   = <<-EOF
    Naseweis is a library that allows you to gather information based on
    questions which are defined in yaml files. This lets you keep your data and
    logic separated and avoids cluttering your code with many calls to
    puts/gets. It also allows you to keep your questions organized, centralized
    and language-agnostic.
  EOF
  spec.homepage      = "https://github.com/Kingdread/Naseweis"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.extra_rdoc_files = ["README.md", "WEISHEIT.md"]
  spec.rdoc_options << "--title" << "Naseweis Documentation" <<
                       "--main" << "README.md"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "highline", "~> 1.7"
end
