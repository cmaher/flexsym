require_relative 'flexsymtax'

module Flexsym
    class Flexsymast
        CODES = {
            0x0 => Flexsymtax::O_SUCC,
            0x1 => Flexsymtax::O_PRED,
            0x2 => Flexsymtax::O_LEFT,
            0x3 => Flexsymtax::O_RIGHT,
            0x4 => Flexsymtax::O_OUTA,
            0x5 => Flexsymtax::O_OUTD,
            0x6 => Flexsymtax::O_VOID,
            0xF => :quote
        }
    end
end
