# EM::Ventually

Your tests will eventually pass. You're not sure when, but you know it'll be quick. This is where EM::Ventually can help you!

Take this trivial example. (It's in Minitest, but you can use whatever test suite you'd like*)

~~~~~ {ruby}
    def test_em_simple
      val = nil
      EM.add_timer(0.5) { val = 'test' }
    end
~~~~~

So, you want to test that val is 'test', and as well, you want EM to start on the beginning of your test and shutdown when it's done. The other thing you want is the ability to not let this test run forever, but to shutdown EM and consider it a failure if it doesn't complete.

**Eventually is here to help!**

Taking the example above you can enqueue a test.

~~~~~ {ruby}
    def test_em_simple
      val = nil
      EM.add_timer(0.5) { val = 'test' }
      eventually('test') { val }
    end
~~~~~

This will poll your block every 0.1 seconds to see if the condition is true. After one second, if it's still not true, it will fail. You can mess with both values by passing in `:every` and `:total`. For example:

~~~~~ {ruby}
    def test_em_simple
      val = nil
      EM.add_timer(0.5) { val = 'test' }
      eventually('test', :every => 0.2, :total => 10) { val } # check every 0.2 seconds
                                                              # for a total of 10 seconds.
    end
~~~~~

You can also parallelize tests if you don't want them to run serially.

~~~~~ {ruby}
    def test_em_simple
      val1, val2 = nil, nil
      EM.add_timer(0.5) { val1 = 'test1' }
      EM.add_timer(0.5) { val2 = 'test2' }
      parallel do
        eventually('test1') { val1 }
        eventually('test2') { val2 }
      end
    end
~~~~~

As well, simple returning doesn't always cover your test. You can pass values back for equality by doing the following.

~~~~~ {ruby}
    def test_em_simple
      val = nil
      EM.add_timer(0.5) { val = 'test1' }
      eventually('test1') { |value| value.call(val1) } # The secret sauce is if you called
                                                       # `eventually` with a parameter or not.
    end
~~~~~

Right now, `Test::Unit`, `RSpec` and `MiniTest` are supported. Just do `include EM::Ventually` in your test and you'll get all this for free.

