require_relative "../r65"

module C64

  class Program < R65::Program

    def write_and_run (filename = nil, debug: false)
      filename = write filename
      if debug
        symbols = as_symbols.map do |sym|
          label = sym[:label].gsub(":",".")
          "al %04x %s" % [sym[:address], label]
        end
        symbols_file = filename + ".sym"
        File.open symbols_file, "wb" do |file|
          file.print symbols.join("\n")
        end
        puts "#{symbols.size} symbols written to #{symbols_file}"
        exec "x64", "-moncommands", symbols_file, "-autostartprgmode", "1", filename
      else
        exec "x64", "-autostartprgmode", "1", filename
      end

    end

  end

end
