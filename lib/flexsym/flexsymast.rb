require_relative 'unflexsymast'

module Flexsym
    class Flexsymast

        # Nibble code for QUOTE
        Q_N = 0xF
        CODES = {
            0x0 => Unflexsymast::C_SUCC,
            0x1 => Unflexsymast::C_PRED,
            0x2 => Unflexsymast::C_LEFT,
            0x3 => Unflexsymast::C_RIGHT,
            0x4 => Unflexsymast::C_OUTA,
            0x5 => Unflexsymast::C_OUTD,
            0x6 => Unflexsymast::C_VOID,
            Q_N => Unflexsymast::C_QUOTE
        }

        def parse
            quoting = false
            @source.each_byte do |b|
                # High-order, Low-order nibbles
                nibbles = [b >> 4, b & 0x0F]
                nibbles.each do |n|  
                    quoting = !quoting if n == Q_N
                    if quoting
                        code = n.chr
                    else
                        code = CODES[n] ? CODES[n] : n.to_s(16)
                    end
                    @unflex << code
                end
            end
            Unflexsymast.new(@unflex).parse
        end

        def initialize(source)
            @source_file = source_file
            @unflex = []
        end
    end
end
