require_relative "../r65"

module C64

  module ProgramExtensions

    def write_and_run (filename = nil, debug: false)
      filename = write filename
      if debug
        labels = as_symbols.map do |sym|
          label = sym[:label].to_s.gsub(":",".")
          "al %04x %s" % [sym[:address], label]
        end
        checkpoints = as_symbols.filter{|sym|sym[:label].checkpoints.any?}.map{|sym|
          label = sym[:label].to_s.gsub(":",".")
          sym[:label].checkpoints.map do |checkpoint|
            if checkpoint.condition
              "%s %s if %s" % [checkpoint.kind, label, checkpoint.condition]
            else
              "%s %s" % [checkpoint.kind, label]
            end
          end
        }.flatten
        symbols_file = filename + ".sym"
        File.open symbols_file, "w" do |file|
          file.print labels.join("\n")
          file.print "\n"
          file.print checkpoints.join("\n")
          file.print "\n"
        end
        puts "#{labels.size} labels and #{checkpoints.size} checkpoints written to #{symbols_file}"
        exec "x64", "-moncommands", symbols_file, "-autostartprgmode", "1", filename
      else
        exec "x64", "-autostartprgmode", "1", filename
      end

    end

  end

end
