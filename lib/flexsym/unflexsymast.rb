require 'rparsec'
require_relative 'flexsymtax'

module Flexsym
    class Unflexsymast
        include RParsec::Parsers

        C_SUCC  = ?+
        C_PRED  = ?-
        C_LEFT  = ?<
        C_RIGHT = ?>
        C_OUTA  = ?^
        C_OUTD  = ?. 
        C_VOID  = ?_
        C_QUOTE = ?;
       
        OPS = [C_SUCC, C_PRED, C_LEFT, C_RIGHT, C_OUTA, C_OUTD, C_VOID]

        OPCODES = {
            C_SUCC  => Flexsymtax::O_SUCC,
            C_PRED  => Flexsymtax::O_PRED, 
            C_LEFT  => Flexsymtax::O_LEFT,
            C_RIGHT => Flexsymtax::O_RIGHT,
            C_OUTA  => Flexsymtax::O_OUTA,
            C_OUTD  => Flexsymtax::O_OUTD,
            C_VOID  => Flexsymtax::O_VOID,
        }

        HEX = *(?a..?z), *(?A..?Z), *(?0..?9)
        
        # Ignore all non-(ops | quotes)
        def parser_ignore!
           not_among(*OPS, C_QUOTE).many
        end

        # Ignore all non-(ops | quotes | hexdigits) 
        def parser_ignore
            not_among(*OPS, C_QUOTE, *HEX).many
        end

        def parser_label
            quote = char C_QUOTE
            text = not_among(C_QUOTE).many
            parser_ignore! >> sequence(quote, text, quote) do |_, chars, _|
                Flexsymtax.label(chars.join)
            end
        end

        def parser_num
            hexnum = among(*HEX).many.map{|digits| digits.join}
            parser_ignore >> hexnum.map{|num| Flexsymtax.num(num.to_i(16))}
        end

        def parser_op
            parser_ignore! >> among(*OPS).map{|op| Flexsymtax.op(OPCODES[op])}
        end

        def parser_block
            cmd = parser_op | parser_label
            parser_ignore! >> cmd.repeat(4, 4).map do |c1, c2, c3, c4|
                Flexsymtax.block(c1, c2, c3, c4)
            end
        end

        def parser_branch
            parser_ignore >> sequence(parser_num, parser_block) do |condition, block|
                Flexsymtax.branch(condition, block)
            end
        end

        def parser_state
            branches = parser_branch.many
            parser_ignore! >> 
                sequence(parser_label, parser_block, branches) do |ref, default, branches|
                Flexsymtax.state(ref, default, branches)
            end
        end

        def parser_program
            states = parser_state.many(1)
            parser_ignore! >> sequence(parser_label, states) do |main_ref, states|
                Flexsymtax.program(main_ref, states)
            end
        end

        def parse
            parser_program.parse(@source)
        end

        # Read the string and parse it 
        def initialize(source_string)
            @source = source_string
        end
    end
end
