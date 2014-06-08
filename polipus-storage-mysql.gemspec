# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'polipus-storage-mysql'
  spec.version       = '0.0.1'
  spec.authors       = ['Francesco Laurita']
  spec.email         = ['francesco.laurita@gmail.com']
  spec.summary       = %q(TODO: Write a short summary. Required.)
  spec.description   = %q(TODO: Write a longer description. Optional.)
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'polipus', '~> 0.3', '>= 0.3.0'
  spec.add_runtime_dependency 'mysql2', '~> 0.3', '>= 0.3.16'

  spec.add_development_dependency 'rspec', '~> 2.99', '>= 2.99.0'
  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
end
