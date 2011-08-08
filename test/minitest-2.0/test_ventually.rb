class TestMounting < MiniTest::Unit::TestCase
  include EM::Ventually

  def test_simple
    assert_equal 1, 1
  end

  def test_em_simple
    val = nil
    EM.add_timer(0.5) { val = 'test' }
    eventually('test') { val }
  end

  def test_em_passing
    val = nil
    EM.add_timer(0.5) { val = 'test' }
    eventually('test') {|m| m[val] }
  end

  def test_multiple
    val = nil
    EM.add_timer(0.3) { val = 'test' }
    EM.add_timer(0.8) { val = 'test2' }
    eventually('test') {|m| m[val] }
    eventually('test2') {|m| m[val] }
  end

  def test_out_of_order # this should fail
    val = nil
    EM.add_timer(0.3) { val = 'test2' }
    EM.add_timer(0.8) { val = 'test' }
    eventually('test') {|m| m[val] }
    eventually('test2') {|m| m[val] }
  end

  def test_out_of_order_with_parallel
    val = nil
    EM.add_timer(0.3) { val = 'test2' }
    EM.add_timer(0.8) { val = 'test' }
    parallel {
      eventually('test') {|m| m[val] }
      eventually('test2') {|m| m[val] }
    }
  end
end