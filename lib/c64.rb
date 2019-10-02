Dir[File.join(__dir__, "c64", "**", "*.rb")]
  .each{|f|require_relative f}

# extensions

class String
  prepend C64::Tables
end
