require 'rparsec'
require 'flexsym/flexsymtax'

module Flexsym
  class Flexsymast
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

    HEX = *(?a..?f), *(?A..?F), *(?0..?9)

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
      sequence(quote, text, quote) do |_, chars, _|
        Flexsymtax.label(chars.join)
      end
    end

    def parser_num
      minus = char C_PRED
      hexnum = among(*HEX).many(1).map{ |digits| digits.join }
      neg_hexnum = minus >> hexnum.map{ |num| "-" << num }

      (neg_hexnum | hexnum).map do |h|
        Flexsymtax.num(h.to_i(16)) 
      end
    end

    def parser_op
      among(*OPS).map{ |op| Flexsymtax.op(OPCODES[op]) }
    end

    def parser_command
      parser_op | parser_label
    end

    def parser_block
      command_skip = parser_command << parser_ignore!
      sequence(command_skip,
               command_skip,
               command_skip,
               parser_command) do |c1, c2, c3, c4|
        Flexsymtax.block(c1, c2, c3, c4)
               end
    end

    def parser_branch
      sequence(parser_num, 
               parser_ignore! >> parser_block) do |condition, block|
        Flexsymtax.branch(condition, block)
               end
    end

    def parser_state
      branches = (parser_branch << parser_ignore).many
      sequence(parser_ignore! >> parser_label,
               parser_ignore! >> parser_block,
               parser_ignore >> branches) do |ref, default, bs|
        Flexsymtax.state(ref, default, bs)
               end
    end

    def parser_program
      states = (parser_state << parser_ignore!).many(1)
      parser_ignore! >> sequence(parser_label, states) do |main_ref, s|
        Flexsymtax.program(main_ref, s)
      end
    end

    def parse
      parse_string(@source)
    end

    def parse_string(str)
      parser_program.parse(str)
    end

    # Read the string and parse it 
    def initialize(source_string='')
      @source = source_string
    end
  end
end
