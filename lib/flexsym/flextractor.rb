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

    def self.extract(ast)
      case type = ast.shift
      when Flexsymtax::L_PROGRAM
        main = Label.extract(ast.shift)

        state_arr = ast.shift.map do |state_ast|
          s = State.extract(state_ast)
          [s.label.value, s]
        end

        state_hash = Hash[state_arr]
        Program.new(main, state_hash)
      else 
        FlexReport.error(type, ast, Flexsymtax::L_PROGRAM)
      end
    end

    def initialize(main, states)
      @main, @states = main, states
    end
  end

  class State
    include FlexReport
    attr_reader :label, :default, :branches

    def self.extract(ast)
      case type = ast.shift
      when Flexsymtax::L_STATE
        label = Label.extract(ast.shift)
        default = Block.extract(ast.shift)
        branches = {}
        ast.shift.each do |branch_ast|
          branch = Branch.extract(branch_ast)
          if branches[branch.condition]
            branches[branch.condition] << branch
          else
            branches[branch.condition] = [branch]
          end
        end
        State.new(label, default, branches)
      else
        FlexReport.error(type, ast, Flexsymtax::L_STATE)
      end
    end

    def initialize(label, default, branches)
      @label, @default, @branches = label, default, branches
    end
  end

  class Branch
    include FlexReport
    attr_reader :condition, :block

    def self.extract(ast)
      case type = ast.shift
      when Flexsymtax::L_BRANCH
        condition = Num.extract(ast.shift).value
        block = Block.extract(ast.shift)
        Branch.new(condition, block)
      else
        FlexReport.error(type, ast, Flexsymtax::L_BRANCH)
      end
    end

    def initialize(condition, block)
      @condition, @block = condition, block
    end
  end

  class Block
    include FlexReport
    attr_reader :commands

    def self.extract(ast)
      case type = ast.shift
      when Flexsymtax::L_BLOCK
        cmds = ast.map do |cmd_ast|
          case optype = cmd_ast[0]
          when Flexsymtax::L_OP 
            Op.extract(cmd_ast)
          when Flexsymtax::L_LABEL 
            Label.extract(cmd_ast)
          else
            FlexReport.error(optype, ast, Flexsymtax::L_OP, Flexsymtax::L_LABEL)
          end
        end
        Block.new(*cmds)
      else
        FlexReport.error(type, ast, Flexsymtax::L_BLOCK)
      end
    end

    def initialize(*cmds)
      @commands = {}
      cmds.each do |cmd|
        case cmd
        when Op     then add_op(cmd.opcode)
        when Label  then @commands[:trans] = cmd.value
        end
      end
    end

    protected

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
      case type = ast.shift
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

    def self.extract(ast)
      case type = ast.shift
      when Flexsymtax::L_LABEL
        label = ast.shift
        Label.new(label)
      else
        FlexReport.error(type, ast, Flexsymtax::L_LABEL)
      end
    end

    def initialize(value)
      @value = value
    end
  end

  class Num
    include FlexReport
    attr_reader :value

    def self.extract(ast)
      case type = ast.shift
      when Flexsymtax::L_NUM
        num = ast.shift
        Num.new(num)
      else
        FlexReport.error(type, ast, Flexsymtax::L_NUM)
      end
    end

    def initialize(value)
      @value = value
    end
  end
end
