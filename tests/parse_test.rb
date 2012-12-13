require 'test/unit'
require 'rparsec'
require 'flexsym/unflexsymast'
require 'flexsym/flexsymast'
require 'flexsym/flexsymtax'

class TestParse < Test::Unit::TestCase
    include Flexsym
    ParserException = RParsec::ParserException

    def setup
        @unflex = Unflexsymast.new('')
        @flex = Flexsymast.new('')
    end

    def test_p_ignore_accept!
        no_ignore = [*Unflexsymast::OPS, Unflexsymast::C_QUOTE]
        ignore = ['', ' ', "!@\#$%&*()=\u1234\u0123\u6fab", 
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
        ignore = ['', ' ', "!@\#$%&*()=\u1234\u0123\u6fab", *(?g..?z), *(?G..?Z)]

        no_ignore.each do |x|
            assert_equal([], @unflex.parser_ignore.parse(x))
        end

        ignore.each do |x|
            assert_equal(x, @unflex.parser_ignore.parse(x).join)
        end
    end

    def test_p_label
        labels = ['abcd', '', ' '].map{|x| [x, ";#{x};"]}
        not_labels = ['abcd', '', ' ']

        labels.each do |xs|
            assert_equal(Flexsymtax::label(xs[0]), @unflex.parser_label.parse(xs[1]))
        end

        not_labels.each do |x|
            assert_raise(ParserException){@unflex.parser_label.parse(x)}
        end
    end

end
