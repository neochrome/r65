require_relative "../constants"
require_relative "../../r65/macros/utils"

module C64
  module Macros
    module IRQ
      module Timers

        Disable = proc do
          lda &CIA1::IRQ::DisableAll
          sta CIA1::IRQ::ControlRegister
          sta CIA2::IRQ::ControlRegister
        end

        Cancel = proc do
          bit CIA1::IRQ::ControlRegister
          bit CIA2::IRQ::ControlRegister
        end

      end

      module Raster

        Enable = proc do
          lda &VIC2::IRQ::Raster
          sta VIC2::IRQ::ControlRegister
          # usually don't need high bit so clear it
          lda VIC2::Control1::Register
          ana &VIC2::Control1::RasterBit8^0xff
          sta VIC2::Control1::Register
          call Ack
        end

        Disable = proc do
          lda VIC2::IRQ::ControlRegister
          eor &VIC2::IRQ::Raster
          sta VIC2::IRQ::ControlRegister
        end

        # cycle count: 6
        Ack = proc do
          asl VIC2::IRQ::StatusRegister
        end

        Install = proc do |address:, line:|
          lda &(address).lo_b
          ldx &(address).hi_b
          sta VIC2::IRQ::VectorLo
          stx VIC2::IRQ::VectorHi
          lda &(line)
          sta VIC2::RasterCounter
        end

        Handler = proc do |address: nil, line: nil, block:|
          raise ArgumentError, "Must supply a proc/block!" unless block.is_a? Proc
          call R65::Macros::Utils::PushState, address: :restore

          call block

          call Install, address: address, line: line unless address.nil?
          call Ack
          label :restore
          call R65::Macros::Utils::PopState
          rti
        end

        StableHandler = proc do |address: nil, line: nil, block:|
          raise ArgumentError, "Must supply a proc/block!" unless block.is_a? Proc
          # elapsed cycles in brackets
          # time to get here                             [07]
          call R65::Macros::Utils::PushState, address: :restore # [19]
          # install next part (stable)
          lda &:stable.lo_b                # [23]
          ldx &:stable.hi_b                # [27]
          sta VIC2::IRQ::VectorLo                 # [31]
          stx VIC2::IRQ::VectorHi                 # [35]
          inc VIC2::RasterCounter                 # [41]
          call Ack                                     # [47]
          # store stack pointer for final exit
          tsx                                          # [49]
          cli                                          # [51]
          # use nops until next raster triggers
          # 6 * 2 = 12
          6.times { nop }                              # [63]
          # one extra for good measure (won't get hit)
          nop
          label :stable
          # restore stack pointer
          txs
          # wait until raster is in border
          call R65::Macros::Utils::WasteCycles, cycles: 45

          call block

          call Install, address: address, line: line unless address.nil?
          call Ack
          label :restore
          call R65::Macros::Utils::PopState
          rti
        end

        class Chain
          def initialize()
            @links = []
          end

          def at(line:, &block)
            @links << { :line => line, :block => block, :stable => false }
            @links.sort_by! {|link|link[:line]}
            self
          end

          def exactly_at(line:, &block)
            @links << { line: line - 2, block: block, stable: true }
            @links.sort_by! {|link|link[:line]}
            self
          end

          def init()
            line = @links.first[:line]
            proc do
              call Install, line: line, address: :"irq#{line}"
            end
          end

          def to_proc(*args,**kwargs,&block)
            links = @links

            proc do
              handler_for = proc do |link, next_link|
                next_label = :"irq#{next_link[:line]}"
                label :"irq#{link[:line]}" do
                  if link[:stable]
                    call StableHandler, line: next_link[:line], address: next_label, &link[:block]
                  else
                    call Handler, line: next_link[:line], address: next_label, &link[:block]
                  end
                end
              end

              for i in 0...links.size - 1
                handler_for.call links[i], links[i + 1]
              end

              handler_for.call links.last, links.first
            end
          end

        end
      end
    end
  end
end
