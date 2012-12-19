module Flexsym
  module Flexsymtax
    #constants for AST node labels
    L_PROGRAM   = :program
    L_STATE     = :state
    L_LABEL     = :label
    L_BRANCH    = :branch
    L_NUM       = :num
    L_BLOCK     = :block
    L_OP        = :op

    #constants for opcodes
    O_SUCC  = :succ
    O_PRED  = :pred
    O_LEFT  = :left
    O_RIGHT = :right
    O_OUTA  = :outa
    O_OUTD  = :outd
    O_VOID  = :void

    OPS = [O_SUCC, O_PRED, O_LEFT, O_RIGHT, O_OUTA, O_OUTD, O_VOID]

    def self.program(main_ref, states)
      [L_PROGRAM, main_ref, states]
    end

    def self.state(ref, default, branches)
      [L_STATE, ref, default, branches]
    end

    def self.label(text)
      [L_LABEL, text]
    end

    def self.branch(condition, block)
      [L_BRANCH, condition, block]
    end

    def self.num(value)
      [L_NUM, value]
    end

    def self.block(cmd1, cmd2, cmd3, cmd4)
      [L_BLOCK, cmd1, cmd2, cmd3, cmd4]
    end

    def self.op(opcode)
      [L_OP, opcode]
    end
  end
end
