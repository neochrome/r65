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

        Install = proc do |handler|
          lda &(handler[:address]).lo_b
          ldx &(handler[:address]).hi_b
          sta VIC2::IRQ::VectorLo
          stx VIC2::IRQ::VectorHi
          lda &(handler[:line])
          sta VIC2::RasterCounter
        end

        Handler = proc do |next_handler = nil, block|
          raise ArgumentError, "Missing block!" unless block.is_a? Proc
          call R65::Macros::Utils::PushState, :restore

          call block

          call Install, next_handler unless next_handler.nil?
          call Ack
          label :restore
          call R65::Macros::Utils::PopState
          rti
        end

        StableHandler = proc do |next_handler = nil, block|
          raise ArgumentError, "Missing block!" unless block.is_a? Proc
          # elapsed cycles in brackets
          # time to get here                             [07]
          call R65::Macros::Utils::PushState, :restore # [19]
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
          call R65::Macros::Utils::WasteCycles, 45

          call block

          call Install, next_handler unless next_handler.nil?
          call Ack
          label :restore
          call R65::Macros::Utils::PopState
          rti
        end

      end
    end
  end
end
