require_relative 'flexsymtax'
require_relative 'flexstractor'

module Flexsym
    class Flexsymancer
        include Flexsymtax

        def initialize(ast)
            @source = ast.dup
        end

        def interpret
            build @source
            run
        end

        protected

        def build(ast)
            @program = Program.extract(ast)
            @machines = [Flexsymachine.new(@program.states, [], @program.main)]
        end


        def run

        end

        # A class to maintain tape and head state
        class Tape
            def initialize
                @tape = [0]
                @head = 0
            end

            # Moves head left, creating new cell if necessary
            def left
                if @head == 0
                    @tape.unshift(0)
                else
                    @head -= 1
                end
            end

            # Moves head right, creating new cell if necessar
            def right
                if @head == @tape.length - 1
                    @tape.push(0)
                    @head += 1
                else
                    @head += 1
                end
            end

            # Returns the value of the tape at the head
            def val
                @tape[@head]
            end
        end
    end
end
