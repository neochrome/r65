require_relative "../r65"

module C64

  class Program < R65::Program

    def run (filename = nil)
      filename = File.basename(Kernel.caller_locations.first.absolute_path, ".rb") + ".prg" unless filename
      write filename
      exec "x64", "-autostartprgmode", "1", filename
    end

  end

end
