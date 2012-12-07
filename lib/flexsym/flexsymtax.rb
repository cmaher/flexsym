module Flexsym
    module Flexsymtax
        def program main_ref, states
            [:program, main_ref, states]
        end

        def state ref, default, branches
            [:state, ref, default, branches]
        end

        def label text
            [:label, text]
        end

        def branch condition, block
            [:branch, condition, block]
        end

        def byte value
            [:byte, value]
        end

        def block op1, op2, op3, op4
            [:block, op1, op2, op3, op4]
        end

        def atom value
            [:atom, value]
        end
    end
end
