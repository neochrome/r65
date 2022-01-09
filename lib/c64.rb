Dir[File.join(__dir__, "c64", "**", "*.rb")]
  .each{|f|require_relative f}

# extensions

class String
  prepend C64::Tables
end

module R65
  class Program
    include C64::ProgramExtensions
  end
end
