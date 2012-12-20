require_relative 'flexsymtax'

module Flexsym
  module FlexReport
    def self.error(type, ast, *labels)
      lstr = [*labels].map{|l| "'#{l}'"}.join(' or ')
      fail "Expected #{lstr} but found--'#{type}--#{ast.to_s}'"
    end
  end

  class Program
    include FlexReport
    attr_reader :main, :states

    def initialize(main, states)
      @main, @states = main, states
    end

    def self.extract(ast)
      ast = ast.dup

      case (type = ast.shift)
      when Flexsymtax::L_PROGRAM
        main = Label.extract(ast.shift)
        states = self.extract_states(ast)
        Program.new(main, states)
      else 
        FlexReport.error(type, ast, Flexsymtax::L_PROGRAM)
      end
    end

    private

    def self.extract_states(ast)
      states = states = ast.shift.map do |state_ast|
        s = State.extract(state_ast)
        [s.label.value, s]
      end
      Hash[states]
    end
  end

  class State
    include FlexReport
    attr_reader :label, :default, :branches

    def initialize(label, default, branches)
      @label, @default, @branches = label, default, branches
    end

    def self.extract(ast)
      ast = ast.dup

      case (type = ast.shift)
      when Flexsymtax::L_STATE
        label = Label.extract(ast.shift)
        default = Block.extract(ast.shift)
        branches = self.extract_branches(ast)
        State.new(label, default, branches)
      else
        FlexReport.error(type, ast, Flexsymtax::L_STATE)
      end
    end

    private

    def self.extract_branches(ast)
      branches = {}

      ast.shift.each do |branch_ast|
        branch = Branch.extract(branch_ast)
        branches[branch.condition] = [] unless branches[branch.condition]
        branches[branch.condition] << branch
      end
      branches
    end

  end

  class Branch
    include FlexReport
    attr_reader :condition, :block

    def initialize(condition, block)
      @condition, @block = condition, block
    end

    def self.extract(ast)
      ast = ast.dup

      case (type = ast.shift)
      when Flexsymtax::L_BRANCH
        condition = Num.extract(ast.shift).value
        block = Block.extract(ast.shift)
        Branch.new(condition, block)
      else
        FlexReport.error(type, ast, Flexsymtax::L_BRANCH)
      end
    end
  end

  class Block
    include FlexReport
    attr_reader :commands

    def initialize(*cmds)
      @commands = {}
      cmds.each do |cmd|
        case cmd
        when Op     then add_op(cmd.opcode)
        when Label  then @commands[:trans] = cmd.value
        end
      end
    end

    def self.extract(ast)
      case (type = ast.shift)
      when Flexsymtax::L_BLOCK
        cmds = self.extract_commands(ast)
        Block.new(*cmds)
      else
        FlexReport.error(type, ast, Flexsymtax::L_BLOCK)
      end
    end

    private

    def self.extract_commands(ast)
      ast.map do |cmd_ast|
        case optype = cmd_ast[0]
        when Flexsymtax::L_OP 
          Op.extract(cmd_ast)
        when Flexsymtax::L_LABEL 
          Label.extract(cmd_ast)
        else
          FlexReport.error(optype, ast, Flexsymtax::L_OP, Flexsymtax::L_LABEL)
        end
      end
    end

    def add_op(opcode)
      case opcode
      when Flexsymtax::O_SUCC, Flexsymtax::O_PRED
        @commands[:tape] = opcode
      when Flexsymtax::O_LEFT, Flexsymtax::O_RIGHT
        @commands[:head] = opcode
      when Flexsymtax::O_OUTA, Flexsymtax::O_OUTD
        @commands[:out]  = opcode
      when Flexsymtax::O_VOID
        @commands[:void] = opcode
      else 
        fail "Unrecognized opcode #{opcode}"
      end
    end
  end

  class Op
    include FlexReport
    attr_reader :opcode

    def self.extract(ast)
      ast = ast.dup

      case (type = ast.shift)
      when Flexsymtax::L_OP
        opcode = ast.shift
        Op.new(opcode)
      else
        FlexReport.error(type, ast, Flexsymtax::L_OP)
      end
    end

    def initialize(opcode)
      @opcode = opcode
    end
  end

  class Label
    include FlexReport
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def self.extract(ast)
      ast = ast.dup

      case (type = ast.shift)
      when Flexsymtax::L_LABEL
        label = ast.shift
        Label.new(label)
      else
        FlexReport.error(type, ast, Flexsymtax::L_LABEL)
      end
    end
  end

  class Num
    include FlexReport
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def self.extract(ast)
      ast = ast.dup

      case (type = ast.shift)
      when Flexsymtax::L_NUM
        num = ast.shift
        Num.new(num)
      else
        FlexReport.error(type, ast, Flexsymtax::L_NUM)
      end
    end
  end
end
