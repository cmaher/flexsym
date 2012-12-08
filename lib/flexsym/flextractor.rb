require_relative 'flexsymtax'

module Flexsym
    class Program
        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_PROGRAM
                main = Label.extract(ast[1])
                states = ast[2].each do |state_ast|
                    State.extract(state_ast)
                end
                Program.new(main, states)
            else 
                fail "Expected ${Flexsymtax::L_PROGRAM} but found--${ast[0]}--${ast}"
            end
        end

        private :new
        def initialize(main, states)
            @main = main
            @states = states
        end
    end

    class State
        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_STATE
                label = Label.extract(ast[1])
                default = Block.extract(ast[2])
                branches = ast[3].each do |branch_ast|
                    Branch.extract(branch_ast)
                end
                State.new(label, default, branches)
            else
                fail "Expected ${Flexsymtax::L_STATE} but found--${ast[0]}--${ast}"
            end
        end

        private :new
        def initialize(label, default, branches)
            @label = label
            @default = default
            @branches = branches
        end
    end

    class Branch
        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_BRANCH
                condition = Num.extract(ast[1])
                block = Block.extract(ast[2])
                Branch.new(condition, block)
            else
                fail "Expected ${Flexsymtax::L_BRANCH} but found--${ast[0]}--${ast}"
            end
        end

        private :new
        def initialize(condition, block)
            @condition = condition
            @block = block
        end
    end

    class Block
        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_BLOCK
                cmds = ast.slice(1,4).each do |cmd_ast|
                    case cmd_ast[0]
                        begin
                            Op.extract(cmd_ast)
                        rescue
                            Label.extract(cmd_ast)
                        end
                    else
                        fail "Expected ${Flexsymtax::L_OP} or ${Flexsymtax::L_LABEL}"\
                             "but found--${cmd_ast[0]}--${cmd_ast}"
                    end
                end
                Block.new(*cmds)
            else
                fail "Expected ${Flexsymtax::L_BLOCK} but found--${ast[0]}--${ast}"
            end
        end

        private :new
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
            when Flexsymtax::O_OUT
                @commands[:out]  = opcode
            when Flexsymtax::O_VOID
                @commands[:void] = opcode
            end
        end
    end

    class Op
        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_OP
                opcode = ast[1]
                Op.new(opcode)
            else
                fail "Expected ${Flexsymtax::L_OP} but found--${ast[0]}--${ast}"
            end
        end

        private :new
        def initialize(opcode)
            @opcode = opcode
        end
    end

    class Label
        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_LABEL
                label = ast[1]
                Label.new(label)
            else
                fail "Expected ${Flexsymtax::L_Label} but found--${ast[0]}--${ast}"
            end
        end

        private :new
        def initialize(label)
            @label = label
        end
    end

    class Num
        def self.extract(ast)
            case ast[0]
            when Flexsymtax::L_NUM
                s_int = ast[1]
                Num.new(s_int)
            else
                fail "Expected ${Flexsymtax::L_NUM} but found--${ast[0]}--${ast}"
            end
        end

        private :new
        def initialize(s_int)
            @vaule = Integer(s_int)
        end
    end
end
