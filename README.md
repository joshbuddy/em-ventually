# EM::Ventually

## Background

Your tests will eventually pass. You're not sure when, but you know it'll be quick. This is where EM::Ventually can help you!

Take this trivial example. (It's in Minitest, but you can use whatever test suite you'd like*)

~~~~~ {ruby}
    def test_em_simple1
      val = nil
      EM.add_timer(0.5) { val = 'test' }
    end
~~~~~

So, you want to test that val is 'test', and as well, you want EM to start on the beginning of your test and shutdown when it's done. The other thing you want is the ability to not let this test run forever, but to shutdown EM and consider it a failure if it doesn't complete.

**EM::Ventually is here to help!**

`EM::Ventually` will take care to start and stop EventMachine, and make sure your tests run serially (unless you don't want them to). It will also prevent your tests from running forever.

Taking the example above you can enqueue a test.

~~~~~ {ruby}
    def test_em_simple2
      val = nil
      EM.add_timer(0.5) { val = 'test' }
      eventually('test') { val }
    end
~~~~~

This will poll your block every 0.1 seconds to see if the condition is true. After one second, if it's still not true, it will fail. You can mess with both values by passing in `:every` and `:total`. For example:

~~~~~ {ruby}
    def test_em_simple3
      val = nil
      EM.add_timer(0.5) { val = 'test' }
      eventually('test', :every => 0.2, :total => 10) { val } # check every 0.2 seconds
                                                              # for a total of 10 seconds.
    end
~~~~~

You can also parallelize tests if you don't want them to run serially.

~~~~~ {ruby}
    def test_em_simple4
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
    def test_em_simple5
      val = nil
      EM.add_timer(0.5) { val = 'test1' }
      eventually('test1') { |with| with[val] } # The secret sauce is if you called
                                                # `eventually` with a block that takes a parameter or not.
    end
~~~~~

## Usage

Right now, `Test::Unit`, `RSpec` and `MiniTest` are supported. Just do `include EM::Ventually` in your test and you'll get all this for free. If you want to use this in all your tests, you can `require 'em-ventually/{minitest,unittest,rspec}'` your appropriate test suite.

There are a couple of global options you can mess with too. `EM::Ventually.every_default=` and `EM::Ventually.total_default=` can both set global `:every` and `:total` times for your tests.

If you don't pass a value to eventually, it will test that your value is true (in the ruby sense). Optionally, you can call `.test` to pass a custom tester.

~~~~~ {ruby}
    def test_em_with_test6
      count = 0
      EM.add_periodic_timer(0.01) { count += 0.5 }
      eventually { count }.test{ |v| v >= 3 }
    end
~~~~~
