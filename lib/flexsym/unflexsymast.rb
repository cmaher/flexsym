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
        
        def self.parser_ignore
           not_among(*OPS, C_QUOTE, *%w{0 1 2 3 4 5 6 7 8 9}).many
        end

        def self.parser_label
            quote = char C_QUOTE
            text = not_among(C_QUOTE).many
            self.parser_ignore >> sequence(quote, text, quote) do |_, chars, _|
                Flexsymtax.label(chars.join)
            end
        end

        def self.parser_num
            self.parser_ignore >> integer.map{|num| Flexsymtax.num(num)}
        end

        def self.parser_op
            self.parser_ignore >> among(*OPS).map{|op| Flexsymtax.op(OPCODES[op])}
        end

        def self.parser_block
            cmd = self.parser_op | self.parser_label
            self.parser_ignore >> cmd.repeat(4, 4).map do |c1, c2, c3, c4|
                Flexsymtax.block(c1, c2, c3, c4)
            end
        end

        def self.parser_branch
            self.parser_ignore >> sequence(self.parser_num, self.parser_block) do |condition, block|
                Flexsymtax.branch(condition, block)
            end
        end

        def self.parser_state
            branches = self.parser_branch.many
            self.parser_ignore >> 
                sequence(self.parser_label, self.parser_block, branches) do |ref, default, branches|
                Flexsymtax.state(ref, default, branches)
            end
        end

        def self.parser_program
            states = self.parser_state.many(1)
            self.parser_ignore >> sequence(self.parser_label, states) do |main_ref, states|
                Flexsymtax.program(main_ref, states)
            end
        end

        def parse
            self.parser_program.parse(@source)
        end

        # Read the string and parse it 
        def initialize(source_string)
            @source = source_string
        end
    end
end
