require 'parser/current'

require_relative './ast'
require_relative './inspector/version'

module Inspector
  module Expectations
    include AST::Patterns

    def has_binding?(binding)
      has_declaration? do |declaration|
        declaration.match(
            _case(p(:lvasgn, v, _)) { |v| v == binding },
            _case(p(:def, v, _, _)) { |v| v == binding },
            _case(p(:class, p(:const, p(:cbase), v), _, _)) { |v| v == binding },
            _case(p(:class, p(:const, nil, v), _, _)) { |v| v == binding },
            _case(p(:module, p(:const, p(:cbase), v), _)) { |v| v == binding },
            _case(p(:module, p(:const, nil, v), _)) { |v| v == binding },
            _case(_) { false })
      end
    end
  end

  def has_usage?(binding, target)
    has_expression?(binding) do |expression|
      expression.match(
          _case(p(:send, _, v)) { |v| v == target },
          _case(p(:send, p(:const, nil, v), _)) { |v| v == target })
    end
  end

  module Syntax
    def has_declaration?(&f)
      declarations.any?(&f)
    end

    def declarations
      if ast.type == :begin
        ast.children.select(&:declaration?)
      elsif ast.declaration?
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
