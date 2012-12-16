require 'test/unit'
require 'rparsec'
require 'flexsym'

class TestParse < Test::Unit::TestCase
    include Flexsym
    ParserException = RParsec::ParserException

    def setup
        @unflex = Unflexsymast.new('')
    end

    def test_p_ignore!
        no_ignore = [*Unflexsymast::OPS, Unflexsymast::C_QUOTE]
        ignore = ['', ' ', "!@\#$%&*()=\u1234\u0123\u6fab\n\t\r", 
            *(?a..?z), *(?A..?Z), '01234567890abcdefABCDEF', *Unflexsymast::HEX]

        no_ignore.each do |x|
            assert_equal([], @unflex.parser_ignore!.parse(x))
        end

        ignore.each do |x|
            assert_equal(x, @unflex.parser_ignore!.parse(x).join)
        end
    end

    def test_p_ignore
        no_ignore = [*Unflexsymast::OPS, Unflexsymast::C_QUOTE, *Unflexsymast::HEX]
        ignore = ['', ' ', "!@\#$%&*()=\u1234\u0123\u6fab\n\t\r", *(?g..?z), *(?G..?Z)]

        no_ignore.each do |x|
            assert_equal([], @unflex.parser_ignore.parse(x))
        end

        ignore.each do |x|
            assert_equal(x, @unflex.parser_ignore.parse(x).join)
        end
    end

    def test_p_label
        labels = ['label', '', ' '].map{|x| [x, ";#{x};"]}
        not_labels = ['abcd', '', ' ']

        labels.each do |xs|
            assert_equal(Flexsymtax::label(xs[0]), @unflex.parser_label.parse(xs[1]))
        end

        not_labels.each do |x|
            assert_raise(ParserException){@unflex.parser_label.parse(x)}
        end
    end

    def test_p_num
        nums_3 = Unflexsymast::HEX.permutation(3).map{|xs| xs.join}
        nums = [*Unflexsymast::HEX, *nums_3, *nums_3.map{|x| "-" << x}]
        not_nums = ['', ';abc;', *(?g..?z), *(?G..?Z), '+', '-', 'x' ] 

        nums.each do |x|
            assert_equal(Flexsymtax::num(x.to_i(16)), @unflex.parser_num.parse(x))
        end

        not_nums.each do |x|
            assert_raise(ParserException){@unflex.parser_num.parse(x)}
        end
    end

    def test_p_op
        ops = [*Unflexsymast::OPS]
        not_ops = ['', Unflexsymast::C_QUOTE]

        ops.each do |x|
            assert_equal(Flexsymtax::op(Unflexsymast::OPCODES[x]), @unflex.parser_op.parse(x))
        end

        not_ops.each do |x|
            assert_raise(ParserException){@unflex.parser_num.parse(x)}
        end
    end

    def test_p_block
        block_opts = [*Unflexsymast::OPS, ';label;']
        permute_blocks = lambda do |n|
            block_opts.repeated_permutation(n).to_a
        end

        blocks = permute_blocks.call(4) 
        not_blocks = ['', *block_opts, *permute_blocks.call(3).map{|x| x.join}]

        blocks.each do |xs|
            ys = xs.map{|y| @unflex.parser_command.parse(y)}
            assert_equal(Flexsymtax::block(*ys), @unflex.parser_block.parse(xs.join))
        end

        not_blocks.each do |xs|
            assert_raise(ParserException){@unflex.parser_block.parse(xs)}
        end
    end
end
