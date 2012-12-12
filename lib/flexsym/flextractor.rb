require_relative 'flexsymtax'

module Flexsym
    class Program
        attr_reader :main, :states

        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_PROGRAM
                main = Label.extract(ast[1])
                states = ast[2].each do |state_ast|
                    State.extract(state_ast)
                end
                Program.new(main, states)
            else 
                fail "Expected #{Flexsymtax::L_PROGRAM} but found--#{ast[0]}--#{ast}"
            end
        end

        private_class_method :new
        def initialize(main, states)
            @main, @states = main, states
        end
    end

    class State
        attr_reader :label, :default, :branches

        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_STATE
                label = Label.extract(ast[1])
                default = Block.extract(ast[2])
                branches = {}
                ast[3].each do |branch_ast|
                   branch = Branch.extract(branch_ast)
                   if branches[branch.condition]
                       branches[branch.condition] << branch
                   else
                       branches[branch.condition] = [branch]
                   end
                end
                State.new(label, default, branches)
            else
                fail "Expected #{Flexsymtax::L_STATE} but found--#{ast[0]}--#{ast}"
            end
        end

        private_class_method :new
        def initialize(label, default, branches)
            @label, @default, @branches = label, default, branches
        end
    end

    class Branch
        attr_reader :condition, :block

        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_BRANCH
                condition = Num.extract(ast[1])
                block = Block.extract(ast[2])
                Branch.new(condition, block)
            else
                fail "Expected #{Flexsymtax::L_BRANCH} but found--#{ast[0]}--#{ast}"
            end
        end

        private_class_method :new
        def initialize(condition, block)
            @condition, @block = condition, block
        end
    end

    class Block
        attr_reader :commands

        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_BLOCK
                cmds = ast.slice(1,4).each do |cmd_ast|
                    case cmd_ast[0]
                    when Flexsymtax::L_OP 
                        Op.extract(cmd_ast)
                    when Flexsymatax::L_LABEL 
                        Label.extract(cmd_ast)
                    else
                        fail "Expected #{Flexsymtax::L_OP} or #{Flexsymtax::L_LABEL}"\
                             "but found--#{cmd_ast[0]}--#{cmd_ast}"
                    end
                end
                Block.new(*cmds)
            else
                fail "Expected #{Flexsymtax::L_BLOCK} but found--#{ast[0]}--#{ast}"
            end
        end

        private_class_method :new
        def initialize(*cmds)
            @commands = {}
            cmds.each do |cmd|
                case cmd
                when Op     then add_op(cmd.opcode)
                when Label  then @commands[:trans] = cmd.label
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
            end
        end
    end

    class Op
        attr_reader :opcode

        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_OP
                opcode = ast[1]
                Op.new(opcode)
            else
                fail "Expected #{Flexsymtax::L_OP} but found--#{ast[0]}--#{ast}"
            end
        end

        private_class_method :new
        def initialize(opcode)
            @opcode = opcode
        end
    end

    class Label
        attr_reader :label

        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_LABEL
                label = ast[1]
                Label.new(label)
            else
                fail "Expected #{Flexsymtax::L_Label} but found--#{ast[0]}--#{ast}"
            end
        end

        private_class_method :new
        def initialize(label)
            @label = label
        end
    end

    class Num
        attr_reader :value

        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_NUM
                s_int = ast[1]
                Num.new(s_int)
            else
                fail "Expected #{Flexsymtax::L_NUM} but found--#{ast[0]}--#{ast}"
            end
        end

        private_class_method :new
        def initialize(s_int)
            @value = Integer(s_int)
        end
    end
end
