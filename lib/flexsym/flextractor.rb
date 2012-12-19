require_relative 'flexsymtax'

module Flexsym
    class Program
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
                fail "Expected #{Flexsymtax::L_PROGRAM} but found--#{type}--#{ast.to_s}"
            end
        end

        def initialize(main, states)
            @main, @states = main, states
        end
    end

    class State
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
                fail "Expected #{Flexsymtax::L_STATE} but found--#{type}--#{ast.to_s}"
            end
        end

        def initialize(label, default, branches)
            @label, @default, @branches = label, default, branches
        end
    end

    class Branch
        attr_reader :condition, :block

        def self.extract(ast)
            case type = ast.shift
            when Flexsymtax::L_BRANCH
                condition = Num.extract(ast.shift).value
                block = Block.extract(ast.shift)
                Branch.new(condition, block)
            else
                fail "Expected #{Flexsymtax::L_BRANCH} but found--#{type}--#{ast.to_s}"
            end
        end

        def initialize(condition, block)
            @condition, @block = condition, block
        end
    end

    class Block
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
                        fail "Expected #{Flexsymtax::L_OP} or #{Flexsymtax::L_LABEL}"\
                             "but found--#{optype}--#{cmd_ast.to_s}"
                    end
                end
                Block.new(*cmds)
            else
                fail "Expected #{Flexsymtax::L_BLOCK} but found--#{type}--#{ast.to_s}"
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
        attr_reader :opcode

        def self.extract(ast)
            case type = ast.shift
            when Flexsymtax::L_OP
                opcode = ast.shift
                Op.new(opcode)
            else
                fail "Expected #{Flexsymtax::L_OP} but found--#{type}--#{ast.to_s}"
            end
        end

        def initialize(opcode)
            @opcode = opcode
        end
    end

    class Label
        attr_reader :value

        def self.extract(ast)
            case type = ast.shift
            when Flexsymtax::L_LABEL
                label = ast.shift
                Label.new(label)
            else
                fail "Expected #{Flexsymtax::L_LABEL} but found--#{type}--#{ast.to_s}"
            end
        end

        def initialize(value)
            @value = value
        end
    end

    class Num
        attr_reader :value

        def self.extract(ast)
            case type = ast.shift
            when Flexsymtax::L_NUM
                num = ast.shift
                Num.new(num)
            else
                fail "Expected #{Flexsymtax::L_NUM} but found--#{type}--#{ast.to_s}"
            end
        end

        def initialize(value)
            @value = value
        end
    end
end
