require_relative 'flexsymtax'

module Flexsym
    class Flexsymachine
        def initialize(states, tape, cur_state)
            @states, @tape, @cur_state = states, tape, cur_state
            @halt = false
        end

        def step
            # Init the list of new machines
            next_states = []

            # Get the branches corresponding to the current tape value
            exec = cur_state.branches[@tape.val]
            # Or the default, if no branches match the tape value
            exec = [cur_state.default] if exec.empty?

            # execute each block
            exec.each do |block|
                exec_tape(block)
                exec_out(block)
                exec_head(block)
                exec_trans(block, next_states)
            end

            if next_states.empty?
                # If this block doesn't transition, it's the end of the line
                @halt = true
            else
                # Else, give one of the next states to this machine
                @cur_state = @states(next_states.pop)
            end

            # Return the remaining states (and the tape for duping
            next_states
        end

        # Perform tape cell operation (:succ/:pred)
        def exec_tape(block)
            @tape.cell(block[:tape]) if block[:tape]
        end

        # Perform tape head operation (:left/:right)
        def exec_head(block)
            @tape.head(block[:head]) if block[:head]
        end

        # Perform output (:outa/:outd)
        def exec_out(block)
            val = @tape.val
            case block[:out]
            when Flexsymtax::O_OUTA then print [val].pack('U')
            when Flexsymtax::O_OUTD then print val
            else fail "#{block[:out]} not a vaild output command"
            end
        end

        # Return the transition state
        def exec_trans(block, next_states)
            next_states << block[:trans] if block[:trans]
        end

        def halt?
            @halt
        end
    end
end
