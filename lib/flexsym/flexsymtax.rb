module Flexsym
    module Flexsymtax
        CODES = {
            succ:   0x0,
            pred:   0x1,
            left:   0x2,
            right:  0x3,
            out:    0x4,
            void:   0x5,
            quote:  0xF
        }

        def self.program main_ref, states
            [:program, main_ref, states]
        end

        def self.state ref, default, branches
            [:state, ref, default, branches]
        end

        def self.label text
            [:label, text]
        end

        def self.branch condition, block
            [:branch, condition, block]
        end

        def self.byte value
            [:byte, value]
        end

        def self.block cmd1, cmd2, cmd3, cmd4
            [:block, cmd1, cmd2, cmd3, cmd4]
        end

        def self.op opcode
            [:op, opcode]
        end
    end
end
