require_relative "../r65"

module C64

  module ProgramExtensions

    def write_and_run (filename = nil, debug: false)
      filename = write filename
      if debug
        symbols_file = filename + ".sym"
        write_symbols_and_checkpoints symbols_file
        Process.wait spawn "x64", "-moncommands", symbols_file, "-autostartprgmode", "1", filename
      else
        Process.wait spawn "x64", "-autostartprgmode", "1", filename
      end
    end

    def write_and_debug (filename = nil)
      filename = write filename
      symbols_file = filename + ".sym"
      write_symbols_and_checkpoints symbols_file
      Process.wait spawn "c64-debugger", "-symbols", symbols_file, "-prg", filename
    end

    def write_symbols_and_checkpoints (filename)
      labels = extract_labels
      checkpoints = extract_checkpoints
      File.open filename, "w" do |file|
        file.print labels.join("\n")
        file.print "\n"
        file.print checkpoints.join("\n")
        file.print "\n"
      end
      puts "#{labels.size} labels and #{checkpoints.size} checkpoints written to #{filename}"
    end

    def extract_labels
      as_symbols.map do |sym|
        label = sym[:label].to_s.gsub(":",".")
        "al C:%04x %s" % [sym[:address], label]
      end
    end

    def extract_checkpoints
      as_symbols.filter{|sym|sym[:label].checkpoints.any?}.map{|sym|
        label = sym[:label].to_s.gsub(":",".")
        sym[:label].checkpoints.map do |checkpoint|
          if checkpoint.condition
            "%s %s if %s" % [checkpoint.kind, label, checkpoint.condition]
          else
            "%s %s" % [checkpoint.kind, label]
          end
        end
      }.flatten
    end

  end

end
