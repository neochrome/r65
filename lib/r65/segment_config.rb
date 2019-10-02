require_relative "./segment"

module R65

  class SegmentConfig

    def initialize
      @segments = []
      yield self if block_given?
    end

    def define (name, min: nil, max: nil, start: nil, fill: false)
      min ||= start
      start ||= min
      raise ArgumentError, "At least one of min & start must be specified" unless min or start
      min = min.to_i
      start = start.to_i
      range = min..[start,max || min].max
      if other = @segments.find {|cfg| cfg[:range].intersect? range}
        raise RangeError, "Segment :#{name} would overlap with :#{other[:name]}"
      end
      @segments << { name:name, min:min, max:max, start:start, fill:fill, range:range }
    end

    def to_segments
      @segments
        .sort_by{|cfg|cfg[:min]}
        .reverse
        .reduce([[],nil]){|(segs,last),cfg|
          cfg[:max] = last[:min] if last and not cfg[:max]
          segs << cfg
          [segs,cfg]
        }[0]
        .map{|cfg|
          name = cfg.delete :name
          cfg.delete :range
          Segment.new name, **cfg
        }
    end

  end

end
