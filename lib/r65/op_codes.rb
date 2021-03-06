module R65
  OP_CODES = {
    :adc=>{:abs=>0x6d,:absx=>0x7d,:absy=>0x79,:imm=>0x69,:indx=>0x61,:indy=>0x71,:zpg=>0x65,:zpgx=>0x75},
    :ana=>{:abs=>0x2d,:absx=>0x3d,:absy=>0x39,:imm=>0x29,:indx=>0x21,:indy=>0x31,:zpg=>0x25,:zpgx=>0x35},
    :asl=>{:abs=>0x0e,:absx=>0x1e,:impl=>0x0a,:zpg=>0x06,:zpgx=>0x16},
    :bcc=>{:rel=>0x90},
    :bcs=>{:rel=>0xb0},
    :beq=>{:rel=>0xf0},
    :bit=>{:abs=>0x2c,:zpg=>0x24},
    :bmi=>{:rel=>0x30},
    :bne=>{:rel=>0xd0},
    :bpl=>{:rel=>0x10},
    :brk=>{:impl=>0x00},
    :bvc=>{:rel=>0x50},
    :bvs=>{:rel=>0x70},
    :clc=>{:impl=>0x18},
    :cld=>{:impl=>0xd8},
    :cli=>{:impl=>0x58},
    :clv=>{:impl=>0xb8},
    :cmp=>{:abs=>0xcd,:absx=>0xdd,:absy=>0xd9,:imm=>0xc9,:indx=>0xc1,:indy=>0xd1,:zpg=>0xc5,:zpgx=>0xd5},
    :cpx=>{:abs=>0xec,:imm=>0xe0,:zpg=>0xe4},
    :cpy=>{:abs=>0xcc,:imm=>0xc0,:zpg=>0xc4},
    :dec=>{:abs=>0xce,:absx=>0xde,:zpg=>0xc6,:zpgx=>0xd6},
    :dex=>{:impl=>0xca},
    :dey=>{:impl=>0x88},
    :eor=>{:abs=>0x4d,:absx=>0x5d,:absy=>0x59,:imm=>0x49,:indx=>0x41,:indy=>0x51,:zpg=>0x45,:zpgx=>0x55},
    :inc=>{:abs=>0xee,:absx=>0xfe,:zpg=>0xe6,:zpgx=>0xf6},
    :inx=>{:impl=>0xe8},
    :iny=>{:impl=>0xc8},
    :jmp=>{:abs=>0x4c,:ind=>0x6c},
    :jsr=>{:abs=>0x20},
    :lda=>{:abs=>0xad,:absx=>0xbd,:absy=>0xb9,:imm=>0xa9,:indx=>0xa1,:indy=>0xb1,:zpg=>0xa5,:zpgx=>0xb5},
    :ldx=>{:abs=>0xae,:absy=>0xbe,:imm=>0xa2,:zpg=>0xa6,:zpgy=>0xb6},
    :ldy=>{:abs=>0xac,:absx=>0xbc,:imm=>0xa0,:zpg=>0xa4,:zpgx=>0xb4},
    :lsr=>{:abs=>0x4e,:absx=>0x5e,:impl=>0x4a,:zpg=>0x46,:zpgx=>0x56},
    :nop=>{:impl=>0xea},
    :ora=>{:abs=>0x0d,:absx=>0x1d,:absy=>0x19,:imm=>0x09,:indx=>0x01,:indy=>0x11,:zpg=>0x05,:zpgx=>0x15},
    :pha=>{:impl=>0x48},
    :php=>{:impl=>0x08},
    :pla=>{:impl=>0x68},
    :plp=>{:impl=>0x28},
    :rol=>{:abs=>0x2e,:absx=>0x3e,:impl=>0x2a,:zpg=>0x26,:zpgx=>0x36},
    :ror=>{:abs=>0x6e,:absx=>0x7e,:impl=>0x6a,:zpg=>0x66,:zpgx=>0x76},
    :rti=>{:impl=>0x40},
    :rts=>{:impl=>0x60},
    :sbc=>{:abs=>0xed,:absx=>0xfd,:absy=>0xf9,:imm=>0xe9,:indx=>0xe1,:indy=>0xf1,:zpg=>0xe5,:zpgx=>0xf5},
    :sec=>{:impl=>0x38},
    :sed=>{:impl=>0xf8},
    :sei=>{:impl=>0x78},
    :sta=>{:abs=>0x8d,:absx=>0x9d,:absy=>0x99,:indx=>0x81,:indy=>0x91,:zpg=>0x85,:zpgx=>0x95},
    :stx=>{:abs=>0x8e,:zpg=>0x86,:zpgy=>0x96},
    :sty=>{:abs=>0x8c,:zpg=>0x84,:zpgx=>0x94},
    :tax=>{:impl=>0xaa},
    :tay=>{:impl=>0xa8},
    :tsx=>{:impl=>0xba},
    :txa=>{:impl=>0x8a},
    :txs=>{:impl=>0x9a},
    :tya=>{:impl=>0x98}
  }
end
