require 'flexsym/flexsymtax'

module Flexsym
  class Flexsymachine
    def initialize(states, tape, cur_state)
      @states, @tape, @cur_state = states, tape, cur_state
      @halt = false
    end

    # Performs one iteration on a machine
    # Returns:
    # * A list of new states for nondeterministic branching
    # * The tape, for duplicating and passing to new machines
    def step
      # Init the list of new machines
      next_states = []

      # Get the branches corresponding to the current tape value
      # Or choose the default
      branches = @cur_state.branches[@tape.val]
      if branches
        blocks = branches.map{ |branch| branch.block } 
      else
        blocks = [@cur_state.default]
      end

      # execute each block
      blocks.each do |block|
        cmds = block.commands
        exec_tape(cmds)
        exec_out(cmds)
        exec_head(cmds)
        exec_trans(cmds, next_states)
      end

      if next_states.empty?
        # If this block doesn't transition, it's the end of the line
        @halt = true
      else
        # Else, give one of the next states to this machine
        @cur_state = next_states.pop
      end

      # Return the remaining states (and the tape for duping)
      return next_states, @tape
    end

    # Perform tape cell operation (:succ/:pred)
    def exec_tape(block)
      @tape.cell(block[:tape]) if block[:tape]
    end

    # Perform tape head operation (:left/:right)
    def exec_head(block)
      @tape.move(block[:head]) if block[:head]
    end

    # Perform output (:outa/:outd)
    def exec_out(block)
      val = @tape.val
      case block[:out]
      when Flexsymtax::O_OUTA then print [val].pack('U')
      when Flexsymtax::O_OUTD then print val
      end
    end

    # Return the transition state
    def exec_trans(block, next_states)
      if block[:trans]
        if (s = @states[block[:trans]])
          next_states << s
        else
          fail "Unrecognized state: ;#{block[:trans]};"
        end
      end
    end

    def halt?
      @halt
    end
  end
end
