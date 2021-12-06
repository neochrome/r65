require_relative "./scope"
require_relative "./segment"

module R65

  class Program < Scope

    def initialize (config = nil, &code)
      @segments = config ? config.to_segments : [Segment.new(:default, start: 0x801)]
      @segments.sort_by! {|seg|seg.min}
      super @segments, @segments.first, &code
      assemble!
    end

    def as_bytes (skip_header: false)
      first = @segments.first
      start = first.min
      last = @segments.last
      bytes = [start.lo_b,start.hi_b]
      bytes += @segments
        .reverse
        .drop(1)
        .reverse
        .map{|seg|seg.as_bytes(fill_before: true, fill_after: true)}
        .flatten
      bytes += last.as_bytes(fill_before: true)
      if skip_header
        bytes.drop 2
      else
        bytes
      end
    end

    def write (filename = nil)
      filename = File.basename(Kernel.caller_locations.first.absolute_path, ".rb") + ".prg" unless filename
      File.open filename, "wb" do |file|
        bytes = self.as_bytes.pack("C*")
        file.print bytes
        puts "#{bytes.size} bytes written to #{filename}"
      end
      filename
    end

    def assemble!
      try_with_local_trace do
        @segments.each{|s|s.assemble!}
      end
    end

    def to_s
      @segments.map{|s|s.to_s}.join("\n")
    end

    def as_symbols
      @segments.map(&:as_symbols).flatten
    end

  end

end
