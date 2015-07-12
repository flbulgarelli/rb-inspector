require 'parser/current'
require "inspector/version"

module Inspector
  module Expectations
    def has_binding?(binding)
      declarations.any? do |declaration|
        if declaration.type == :lvasgn
          declaration.children[0].to_s == binding
        elsif declaration.type == :def
          declaration.children[0].to_s == binding
        elsif declaration.type == :class &&  declaration.children[0].type == :const && declaration.children[0].children[0].nil?
          declaration.children[0].children[1].to_s == binding
        end
      end
    end

    def has_usage?(binding, target)

    end

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
