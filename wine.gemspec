unless defined? Wine::VERSION
  $LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

  require 'wine/version'
end

Gem::Specification.new do |s|
  s.name        = "wine"
  s.version     = Wine::VERSION
  s.summary     = "A protocol for configuring and monitoring agents"
  s.description = File.open("README.md") { |f| f.read }
  s.homepage    = "http://github.com/valotrading/wine-ruby"
  s.authors     = [ "Pekka Enberg", "Jussi Virtanen" ]
  s.email       = "engineering@valotrading.com"
  s.license     = "Apache License, Version 2.0"

  s.files = Dir[ 'README.md', 'bin/*', 'lib/**/*.rb' ]

  s.add_dependency 'bindata', '~> 1.4'

  s.add_development_dependency 'rake', '~> 10.0'

  s.executables << 'wine-test-server'
end
