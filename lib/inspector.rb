require 'parser/current'
require "inspector/version"
require 'ostruct'

module AST
  class Node
    def match(*cases)
      cases.each do |it|
        binding = it.pattern.bind(self)
        if binding
          return it.action.call(*binding)
        end
      end
    end

    def components
      [type] + children
    end

  end

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


module Inspector
  module Expectations
    include AST::Patterns

    def has_binding?(binding)
      declarations.any? do |declaration|
        declaration.match(
            _case(p(:lvasgn, v, _)) { |v| v.to_s == binding },
            _case(p(:def, v, _, _)) { |v| v.to_s == binding },
            _case(p(:class, p(:const, p(:cbase), v), _, _)) { |v| v.to_s == binding },
            _case(p(:class, p(:const, nil, v), _, _)) { |v| v.to_s == binding },
            _case(p(:module, p(:const, p(:cbase), v), _)) { |v| v.to_s == binding },
            _case(p(:module, p(:const, nil, v), _)) { |v| v.to_s == binding },
            _case(_) { false })
      end
    end
  end

  def has_usage?(binding, target)

  end

  module Syntax
    def declarations
      if ast.type == :begin
        ast.children.select do |it|
          [:lvasgn, :class, :def, :module].include? it.type
        end
      elsif [:lvasgn, :class, :def, :module].include? ast.type
        [ast]
      else
        []
      end
    end

    def expressions_of(binding)

    end
  end

  class Code
    include Expectations
    include Syntax

    attr_accessor :ast

    def initialize(ast)
      @ast = ast
    end

    def self.parse(code)
      Code.new Parser::CurrentRuby.parse(code)
    end
  end
end
