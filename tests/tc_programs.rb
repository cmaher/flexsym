require 'test/unit'
require 'flexsym'

class TestExamples < Test::Unit::TestCase
    include Flexsym

    def test_hello
        output = `ruby bin/flexsym examples/hello.flexsym`
        assert_equal("Hello, World!\n", output)
    end

    def test_min
        output = `ruby bin/flexsym examples/min.flexsym`
        assert_equal("", output)
    end

    def test_nd4
        output = `ruby bin/flexsym examples/nd4.flexsym`
        assert_equal("4444\n", output)
    end

    def test_sub
        output = `ruby bin/flexsym examples/sub.flexsym`
        assert_equal('-3', output)
    end
end
