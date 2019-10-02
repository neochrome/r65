Dir[File.join(__dir__, "r65", "**", "*.rb")]
  .each{|f|require_relative f}

# extensions
require_relative "./extensions/bytes"
require_relative "./extensions/integer"
require_relative "./extensions/range"

class Integer
  prepend R65::Addressing::ExpressionOperators
  prepend R65::Addressing::IntegerExtensions
  prepend IntegerExtensions
end

class Symbol
  prepend R65::Addressing::ExpressionOperators
  prepend R65::Addressing::SymbolExtensions
end

class Array
  prepend BytesExtensions
end

class Range
  prepend RangeExtensions
end
