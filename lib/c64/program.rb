require_relative "../r65"

module C64

  class Program < R65::Program

    def write_and_run (filename = nil, debug: false)
      filename = write filename
      if debug
        labels = as_symbols.map do |sym|
          label = sym[:label].to_s.gsub(":",".")
          "al %04x %s" % [sym[:address], label]
        end
        checkpoints = as_symbols.filter{|sym|sym[:label].checkpoint.any?}.map{|sym|
          label = sym[:label].to_s.gsub(":",".")
          sym[:label].checkpoint.map do |checkpoint|
            case checkpoint
              when Symbol, String
                ["%s %s" % [checkpoint.to_s, label]]
              when Hash
                checkpoint.each_pair.map{|kind,cond|"%s %s if %s" % [kind, label, cond]}
              else
                raise ArgumentError, "unsupported checkpoint type #{checkpoint.class}"
            end
          end
        }.flatten
        symbols_file = filename + ".sym"
        File.open symbols_file, "wb" do |file|
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
