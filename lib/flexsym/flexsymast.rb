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
            @source_file.each_byte do |b|
                # High-order, Low-order nibbles
                nibbles = [b >> 4, b & 0x0F]
                nibbles.each do |n|  
                    quoting = !quoting if n == Q_N
                    if quoting
                        @source << n.chr
                    elsif CODES[n] 
                        @source << CODES[n]
                    end
                end
            end
            Unflexsymast.new(@source).parse
        end

        def initialize(source_file)
            @source_file = source_file
            @source = []
        end
    end
end
