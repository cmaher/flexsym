module Flexsym
    class Flexsymast
        CODES = {
            0x0 => :succ,
            0x1 => :pred,
            0x2 => :left,
            0x3 => :right,
            0x4 => :out,
            0x5 => :void,
            0xF => :quote
        }
    end
end
