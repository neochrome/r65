module R65

  module Addressing

    class Expression

      def self.from (thing)
        case thing
        when Integer
          ConstantExpression.new thing
        when Symbol
          LabelExpression.new thing
        when Expression
          thing
        else
          raise TypeError, "Unsupported type: #{thing.class} for addressing"
        end
      end

      def self.resolvable? (thing)
        case thing
        when Expression, Symbol
          true
        else
          false
        end
      end

      def to_ary
        [self]
      end

      def method_missing (method)
        ProxyExpression.new self, method
      end

    end

    class ProxyExpression < Expression

      def initialize (expr, method)
        @expr,@method = expr,method
      end

      def resolve! (&lookup)
        @expr.resolve! &lookup
        self
      end

      def pending?
        @expr.pending?
      end

      def value
        @expr.value.send @method
      end

      def to_s
        @expr.to_s
      end

    end

    class ConstantExpression < Expression
      attr_reader :value

      def initialize (value)
        @value = value
      end

      def resolve!
        self
      end

      def pending?
        false
      end

      def to_s
        @value.to_s
      end

    end

    class LabelExpression < Expression
      attr_reader :value

      def initialize (label)
        @label = label
        @pending = true
        @value = nil
      end

      def resolve! (&lookup)
        @value = lookup.call(@label)
        raise NameError, "Could not resolve label :#{@label}" unless @value
        @pending = false
        self
      end

      def pending?
        @pending
      end

      def to_s
        ":" + @label.to_s
      end

    end

    class BinaryExpression < Expression
      attr_reader :value

      def initialize (a,b,op)
        @a,@b,@op = a,b,op
        @value = nil
        @pending = true
        unless @a.pending? or @b.pending?
          @value = @a.value.send(@op, @b.value)
          @pending = false
        end
      end

      def resolve! (&lookup)
        [@a,@b].each{|e|e.resolve! &lookup}
        @value = @a.value.send(@op, @b.value)
        @pending = false
        self
      end

      def pending?
        @pending
      end

      def to_s
        [@a.to_s, @op.to_s, @b.to_s].join(" ")
      end

    end

    module ExpressionOperators

      [:+,:-,:*,:/,:%].each do |op|
        define_method op do |other|
          return super other unless Expression.resolvable? self or Expression.resolvable? other
          BinaryExpression.new (Expression.from self), (Expression.from other), op
        end
      end

      def to_proc
        return super if self.is_a? Symbol
        proc { Expression.from self }
      end

    end

    class Expression
      prepend ExpressionOperators
    end

    module SymbolExtensions
      def hi_b
        Expression.from(self).hi_b
      end
      def lo_b
        Expression.from(self).lo_b
      end
    end

    module IntegerExtensions
      def hi_b
        self >> 8
      end
      def lo_b
        self & 0x00ff
      end
    end
  end

end
