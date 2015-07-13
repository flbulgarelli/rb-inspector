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
end
