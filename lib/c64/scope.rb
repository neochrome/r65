require_relative "../r65"

module C64

  module ScopeExtensions

    def text (text)
      bytes text.to_scr
    end

  end

end

