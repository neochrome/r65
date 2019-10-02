require "nokogiri"

File.open "6502.html" do |file|
  doc = Nokogiri::HTML(file)
  instructions = doc.css('table#opctable tbody tr').map.with_index{|tr,i|
    hi = i * 0x10
    tr.css('td').drop(1).map.with_index{|td,lo|
      opc = hi + lo
      [td,opc]
    }.reject{|td,opc|td[:class] == "undef"}
    .map{|td,opc|
      ins,mode = td.content.split(" ")
      ins.downcase!
      mode = case mode.downcase
      when "impl","a"
        :impl
      when "x,ind"
        :indx
      when "zpg"
        :zpg
      when "#"
        :imm
      when "abs"
        :abs
      when "rel"
        :rel
      when "ind,y"
        :indy
      when "zpg,x"
        :zpgx
      when "abs,y"
        :absy
      when "abs,x"
        :absx
      when "ind"
        :ind
      when "zpg,y"
        :zpgy
      else raise "mode: #{mode}"
      end
      ins = "ana" if ins == "and"
      [ins.to_sym,":#{mode}=>0x%02x" % opc]
    }
  }.flatten(1)
  .reduce({}){|memo,ins|
    ins,mode = ins
    memo[ins] = [] unless memo.has_key? ins
    memo[ins] << mode
    memo
  }.transform_values{|modes|modes.sort.join(",")}
  .to_a
  .map{|ins,modes|":#{ins}=>{#{modes}}"}
  .sort
  .join(",\n")
  puts instructions
end
