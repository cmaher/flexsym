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

        def block cmd1, cmd2, cmd3, cmd4
            [:block, cmd1, cmd2, cmd3, cmd4]
        end

        def op value
            [:op, value]
        end
    end
end
