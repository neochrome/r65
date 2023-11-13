# r65 - a Ruby 65xx macro assembler
r65 is an assembler implemented as a DSL in Ruby. This means all constructs from Ruby are available
at the time of assembling and can be thought of as macros that are expanded in the final binary version.


## Getting started
Create a Gemfile with the following lines:
```ruby
gem "r65" github: "neochrome/r65"                # latest version
gem "r65" github: "neochrome/r65", tag: 'v0.1.0' # specific version
```

And then execute:
```
bundle config path 'vendor/bundle' --local # sets up bundle for local project
bundle install
```

### Quick example: cycle background color
```ruby
require "r65" # 65xx assembling functions & macros
require "c64" # C64 specific constants, macros & loaders

include R65
include C64

prg = Program.new do
  call Macros::Bootstrap do
    label :loop do
      inc VIC2::BackgroundColor
      jmp :loop
    end
  end
end

prg.write_and_run
```

The last line is specific for C64 programs. It assembles the program, writes it
to a file, then launches VICE64 and runs the program.

More examples in [examples](./examples)


### Assembling and emitting binary/text representations of programs
The `Program` class is the container for your program and has methods to assemble and
writing the result to files.

#### #write
The `write` method assembles and writes the resulting binary code to a file with the
basename of the Ruby script + `.prg` extension. Optionally a filename may be supplied.

```ruby
# my_program.rb
Program.new.write     # will assemble and write the resulting program to my_program.prg
```

#### #to_s
The `to_s` method will assemble and return a hex representation of the program together
with symbols.

```ruby
puts Program.new.to_s
```

#### #as_symbols
The `as_symbols` method will assemble and return a list of all the symbols with their final
absolute addresses.

```ruby
puts Program.new.as_symbols
```

## Syntax
All 65xx instructions use the standard mnemonics, except `and`, which is a reserved word in Ruby,
instead use `ana` (ANd Accumulator).  

### Addressing modes

#### Non-indexed, non-memory
```ruby
lsr            # accumulator
lda &0x42      # immediate, prefixed with & (ampersand)
clc            # implied / none
```

#### Non-indexed
```ruby
bne -0x02      # relative backward (only branching)
bne 0x02       # relative forward (only branching)
jmp 0x1234     # absolute
lda 0x12,:z    # absolute, zero-page
jmp [0x1234]   # indirect (only jmp)
```

#### Indexed
```ruby
lda 0x1001,:x  # absolute, x-indexed
lda 0x1002,:y  # absolute, y-indexed
lda 0x11,:zx   # zero-page, x-indexed
ldx 0x12,:zy   # zero page, y-indexed
lda [0x13],:x  # indirect, x-indexed
lda [0x14],:y  # indirect, y-indexed
```

#### Addressing math
```ruby
lda :foo+1     # label + constant
lda :foo+:bar  # label + label
lda :foo.lo_b  # low byte of label address
lda :foo.hi_b  # high byte of label address
lda &:foo.hi_b # high byte of label address, as immediate value
```

### Pseudo instructions

#### Data directives
```ruby
byte 0xee              # simple byte
word 0x1234            # word as two bytes, LE - order
align! 8               # align to next 8 (power of two) address
byte (0x00..0x15).to_a # array of bytes
fill 4, 0x04           # shortcut to fill out n bytes as specified
pc! 0x0054             # sets the program counter to the specified address..
                       # ..and fills the resulting gaps with zeroes
```

#### Segments
A program and it's data may be split into separate sections called segments. This allows a program
to be split into multiple separate files for organizational purposes, while at the same time make sure
the assembles instructions end up in the desired memory locations.
First the program needs to be configured to use different segments, then separate program files may
target the different segments using the `segment` pseudo instruction.

```ruby
# bootstrap.rb
cfg = SegmentConfig.new do |cfg|
    cfg.define :code, start: 0x801
    cfg.define :data, start: 0x2000
end

require_relative "./routine.rb"

prg = Program.new cfg do
    segment! :code   # switch to the :code segment

    lda :my_data
    jsr :some_routine
    rti

    segment :data do # switch to the :data segment for the scope of the block
        label :my_data
        byte 0x01
    end

    call SomeRoutine::Init # execute macro from other file to include the instructions
end

# routine.rb
module SomeRoutine
    Init = proc do
        label :some_routine do
            segment! :code
            lda :my_var
            rts

            segment! :data
            label :my_var
            byte 0x00
        end
    end
end
```

#### Labels and scopes
Labels are used to mark specific places in the code/memory that can later be referred to.
Ruby symbols are used as label names and must be unique within the current scope.
```ruby
label :foo # create the label
# ...
# ...
jmp :foo   # refer to the label
label :foo # error - label must be unique
```

Labels can also be used to introduce a scope by adding a Ruby block after the name. Labels defined
in the scope won't collide with labels from the outer scope and will shadow those with the same name
from the outer scope.
```ruby
label :foo
label :bar do
    label :foo # ok, since inner scope, shadows the outer :foo
    # ...
    # ...
    jmp :foo   # will resolve to the inner scope
end
```

One can also introduce an explicit scope, without using a label:
```ruby
label :foo
scope :scoped do
    label :foo    # ok, since inner scope, shadows the outer :foo
    byte 0x00
end
jmp :"scoped:foo" # it's possible to refer to scoped/nested label by full name
```

### Macros
Macros are plain ruby procs which may have arguments, even nested blocks are possible.
By default macros doesn't introduce a new scope, but it's possible to do so either by
defining a scope using the label or scope pseudo instructions inside the macro, or when
calling / executing the macro.
```ruby
label :foo

AMacro = proc do |arg1:, block:nil|     # macro with a named argument and an optional block
    byte arg1
    call block unless block.nil?
    label :foo                          # error, collides with outer :foo
    scope :inner do
        label :foo                      # ok, inner scope
    end
end

call AMacro, arg1: 0x42                 # calls macro with named argument

call AMacro, arg1: 0x42 do              # calls macro with named argument and block
    label :foo                          # collides with outer :foo
end

call_with_scope AMacro, arg1: 0x42 do   # calls macro with an implicit scope
    label :foo                          # ok, inner implicit scope
    byte 0xff
end
```

### Library macros
r65 comes with some pre-defined macros that may be used.

#### Ext16 - 16 bit math
Helper macros to work with 16 bit numbers.
```ruby
include R65::Macros

call Ext16::SetImmediate, address: 0x1000, value: 0x1010
call Ext16::Copy, source: 0x1000, target: 0x2000
call Ext16::AddImmediate, address: 0x1000, value: 0x1010
call Ext16::SubImmediate, address: 0x1000, value: 0x1010
call Ext16::Add, address: 0x1000, value: 0x2000           # value at address
call Ext16::Sub, address: 0x1000, value: :some_value      # read from address
call Ext16::Increment, address: 0x1000                    # +1
call Ext16::Decrement, address: 0x1000                    # -1
```

#### Push / Pop state
Useful to save state before calling a sub routine. Works by utilizing self modifying code
at the end of the routine to store and read back the state of `X,Y,A` registers.

Args:
 - address: target address to write current state, should be initialized by `PopState`

```ruby
include R65::Macros

label :subroutine do
    call Utils::PushState, address: :exit # stores X,Y,A at the specified address
    lda &0x20                             # do stuff that mutates X,Y,A
    label :exit
    call Utils::PopState                  # loads back the stored values of X,Y,A
    rts
end

jsr :subroutine
```

#### TinyRand
A macro that includes the code to initialize and get random numbers through the `A` register.
```ruby
include R65::Macros

jsr :"tiny_rand:init" # initialize the random generator from a seed in A
jsr :tiny_rand        # call subroutine to get a new random number in A


call TinyRand         # call macro to setup the algorithm at the label :tiny_rand
```

### C64 specific

#### Running and debugging the program
The C64 extension of the `Program` class contains methods to automatically launch VICE64 or the
C64 debugger with the current program.

```ruby
Program.new.write_and_run   # assembles & writes the program to file
                            # then launches VICE64 to run the program

Program.new.write_and_debug # assembles & write the program to file together with a symbols file
                            # then launches C64 debugger with the program & symbols loaded
```

#### C64 Memory mapping constants
There are many pre-defined constants available to help identifying the memory mapping of the C64.
They live in the following modules:
 - C64::DefaultBasic
 - C64::ROMConfig
 - C64::CIA1
 - C64::CIA2
 - C64::VIC2

#### ASCII / PETSCII mapping
Standard ascii strings may have their characters mapped to screen codes the following way:
```ruby
label :message
bytes "MY MESSAGE".to_scr
```

#### VIC2 configuration
Since the VIC2 is quite complex to configure, there's an helper class to make it easier.
```ruby
include C64

vic2 = VIC2::Config.new.bank_at(0x4000).char_at(0x0800)

label :charset
pc! vic2.char # address of character memory of the vic2 config
byte 0,1,2,3  # charset data
```
See full examples at [font](./examples/font.rb) and [sprites](./exmaple/sprites.rb).

#### Bootstrap macro
This macro helps setting up a tiny basic program that immediately executes the program by SYSing
the starting point in memory.

Args:
 - block: instructions for the start of the program, required

```ruby
include C64::Macros

call Macros::Bootstrap do         # the program execution will start in the specified block
    label :loop do
        inc VIC2::BackgroundColor
        jmp :loop
    end
end
```

#### ClearScreen macro
Includes code to clear the screen.

Args:
 - color - defaults to black
 - fillbyte - defaults to space
 - screen - VIC2 default screen

```ruby
include C64::Macros

call Utils::ClearScreen # color - black, fillbyte - space, screen - default
```

#### LoadScreen macro
Includes code to clear the screen.

Args:
 - screen_data: address of screen data, required
 - screen: target screen, defaults to VIC2 default screen
 - color_data: address of color data, optional (nil if not used)
 - color: target color, defaults to VIC2 color

```ruby
include C64::Macros

call Utils::LoadScreen, screen_data: :my_screen, color_data: :my_colors

label :my_screen
bytes 0,1,2,3
label :my_colors
bytes 4,5,6,7
```

#### Raster IRQ handlers
There are some helper macros to setup and working with raster IRQ handlers and chains.
See the examples [raster_bars](./examples/raster_bars.rb) and [raster_bars2](./examples/raster_bars2.rb)
for in-depth usage.

## Development

Install dependencies:
```
bundle install
```

Run tests:
```
bundle exec rake test
```

Cutting a release:
```
bundle exec rake bump:<major|minor|patch>
```
