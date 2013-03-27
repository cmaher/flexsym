require 'flexsym/flexsymtax'

module Flexsym
  class Flexsymachine
    def initialize(states, tape, cur_state)
      @states, @tape, @cur_state = states, tape, cur_state
      @halt = false
    end

    # Performs one iteration on a machine
    # Halts on no new states
    # Returns:
    # * A list of new states for nondeterministic branching
    # * The tape, for duplicating and passing to new machines
    def step
      unless @halt
        next_states = exec_blocks(get_blocks)
        
        if next_states.empty?
          @halt = true
        else
          @cur_state = next_states.pop
        end
        
        return next_states, @tape
      end
    end

    private
    
    # Get the default blocks or blocks for current tape value
    def get_blocks
      if (branches = @cur_state.branches[@tape.val]
        branches.map { |branch| branch.block } 
      else
        [@cur_state.default]
      end
    end
    
    # Execute all of the given blocks and return the new states
    def exec_blocks(blocks)
      blocks.map { |block| exec_commands(block.commands) }
    end
    
    # Execute all of the given commands and return the new state
    def exec_commands(cmds)
      exec_tape(cmds)
      exec_out(cmds)
      exec_head(cmds)
      exec_trans(cmds)
    end

    # Perform tape cell operation (:succ/:pred)
    def exec_tape(cmds)
      @tape.cell(cmds[:tape]) if cmds[:tape]
    end

    # Perform tape head operation (:left/:right)
    def exec_head(cmds)
      @tape.move(cmds[:head]) if cmds[:head]
    end

    # Perform output (:outa/:outd)
    def exec_out(cmds)
      val = @tape.val
      case block[:out]
      when Flexsymtax::O_OUTA then print [val].pack('U')
      when Flexsymtax::O_OUTD then print val
      end
    end

    # Return the transition state
    def exec_trans(cmds)
      if (trans = cmds[:trans] && (next_state = @states[trans])
          next_state
      end
    end

    def halt?
      @halt
    end
  end
end
