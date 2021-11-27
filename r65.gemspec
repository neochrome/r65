require_relative "./lib/r65/version"

Gem::Specification.new do |s|
  s.name        = "r65"
  s.version     = R65::VERSION
  s.summary     = "r65"
  s.description = "A ruby 65xx macro assembler"
  s.authors     = "Johan Stenqvist"
  s.email       = "johan@stenqvist.net"
  s.files       = Dir["**/*.rb"]
  s.homepage    = "https://github.com/neochrome/r65"
  s.license     = "UNLICENSE"

  s.add_dependency "chunky_png", "~> 1.3"
end
