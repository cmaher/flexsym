require_relative 'flexsymtax'
require_relative 'flexstractor'

module Flexsym
    class Flexsymancer
        include Flexsymtax

        def initialize(ast)
            @source = ast.dup
        end

        def interpret
            build
            run
        end

        protected

        def build
            build @source
        end

        def build(ast)
            @program = Program.extract(ast)
        end

        def run
        end
    end
end
