# r65 - a ruby 65xx macro assembler

## Getting started

Installation:
```
gem
```

Example usage: cycle background color
```ruby
require "r65" # 65xx assembling functions & macros
require "c64" # C64 specific constants, macros & loaders

include R65
include C64 # shadows Program with a C64-emulator aware version (#run)

prg = Program.new do
  call Macros::Bootstrap do
    label :loop do
      inc VIC2::BackgroundColor
      jmp :loop
    end
  end
end

prg.run
```

More examples in [examples](./examples)


## Development

Install dependencies:
```
gem install -g
```

Run tests:
```
rake test
```
