require 'flexsym/flexsymtax'
require 'flexsym/flextractor'
require 'flexsym/flexsymachine'

module Flexsym
  class Flexsymancer
    def initialize(ast)
      @source = ast.dup
    end

    def interpret
      build @source
      run
    end

    private

    def build(ast)
      @program = Program.extract(ast)
      main_state = @program.states[@program.main.value]
      @machines = [Flexsymachine.new(@program.states, Tape.new, main_state)]
    end

    def run
      halt = false
      while !halt
        @machines.each do |machine|
          # Step the machine; Get next states and tape
          next_states, tape = machine.step
          # If this machine halted, set halt to true
          halt = halt || machine.halt?
          # Add new machines to list
          next_states.each do |m|
            @machines.push(Flexsymachine.new(@program.states, tape.dup, m))
          end
        end
      end
    end

    # A class to maintain tape and head state
    class Tape
      def initialize
        @tape = [0]
        @head = 0
      end

      # Increase or decrease the cell depending on the op
      def cell(op)
        case op
        when Flexsymtax::O_SUCC then succ
        when Flexsymtax::O_PRED then pred
        else fail "--#{op}-- is not a valid cell operation"
        end
      end

      # Move left or right depending on the direction given
      def move(direction)
        case direction
        when Flexsymtax::O_LEFT then left
        when Flexsymtax::O_RIGHT then right
        else fail "--#{direction}-- is not a valid direction"
        end
      end

      # Returns the value of the tape at the head
      def val
        @tape[@head]
      end

      private

      # Moves head left, creating new cell if necessary
      def left
        if @head == 0
          @tape.unshift(0)
        else
          @head -= 1
        end
      end

      # Moves head right, creating new cell if necessary
      def right
        if @head == @tape.length - 1
          @tape.push(0)
          @head += 1
        else
          @head += 1
        end
      end

      # Tape cell + 1
      def succ
        @tape[@head] += 1
      end

      # Tape cell - 1
      def pred
        @tape[@head] -= 1
      end
    end
  end
end
