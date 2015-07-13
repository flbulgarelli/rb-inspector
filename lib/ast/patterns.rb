require 'ostruct'

module AST
  module Patterns
    class Decons
      def initialize(subpatterns)
        @subpatterns = subpatterns
      end

      def bind(node)
        return if node.nil?
        return unless node.is_a?(AST::Node)
        return if node.components.length != @subpatterns.length

        bindings = @subpatterns.zip(node.components).map { |subpattern, component| subpattern.bind(component) }
        if bindings.all?
          bindings.flatten
        end
      end
    end

    class Literal
      def initialize(value)
        @value = value
      end

      def bind(node)
        if node == @value
          []
        end
      end
    end

    class Variable
      def bind(node)
        [node]
      end
    end

    class AnonymousVariable
      def bind(node)
        []
      end
    end

    def p(*args)
      Decons.new(args.map do |arg|
        if [Variable, AnonymousVariable, Literal, Decons].include? arg.class
          arg
        else
          Literal.new(arg)
        end
      end)
    end

    def v
      Variable.new
    end

    def _
      AnonymousVariable.new
    end

    def _case(pattern, &action)
      OpenStruct.new(pattern: pattern, action: action)
    end

    module_function :p, :v, :_, :_case
  end
end
