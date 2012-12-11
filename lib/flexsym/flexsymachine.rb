require_relative 'flexstractor'

module Flexsym
    class Flexsymachine
        def initialize(states, tape, cur_state)
            @states, @tape, @cur_state = states, tape, cur_state
        end
    end
end
