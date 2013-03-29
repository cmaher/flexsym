require 'test/unit'
require 'flexsym'

class TestExtract < Test::Unit::TestCase
  include Flexsym

  def test_num
    nums = (-255..255).to_a

    nums.each do |n|
      assert_equal(n, Num.extract(Flexsymtax::num(n)).value)
    end
  end

  def test_label
    labels = (?a..?z).to_a.permutation(3)

    labels.each do |n|
      assert_equal(n, Label.extract(Flexsymtax::label(n)).value)
    end
  end

  def test_op
    Flexsymtax::OPS.each do |n|
      assert_equal(n, Op.extract(Flexsymtax::op(n)).opcode)
    end
  end

  def test_block
    test1 = [ Op.new(Flexsymtax::O_SUCC), Op.new(Flexsymtax::O_RIGHT), 
      Op.new(Flexsymtax::O_OUTA), Label.new('t')]
    test2 = [ Op.new(Flexsymtax::O_PRED), Op.new(Flexsymtax::O_LEFT), 
      Op.new(Flexsymtax::O_OUTD), Op.new(Flexsymtax::O_VOID)]

    cmds = Block.new(*test1).commands
    assert_equal(Flexsymtax::O_SUCC, cmds[:tape])
    assert_equal(Flexsymtax::O_RIGHT, cmds[:head])
    assert_equal(Flexsymtax::O_OUTA, cmds[:out])
    assert_equal('t', cmds[:trans])

    cmds = Block.new(*test2).commands
    assert_equal(Flexsymtax::O_PRED, cmds[:tape])
    assert_equal(Flexsymtax::O_LEFT, cmds[:head])
    assert_equal(Flexsymtax::O_OUTD, cmds[:out])
    assert_equal(Flexsymtax::O_VOID, cmds[:void])
  end
end
