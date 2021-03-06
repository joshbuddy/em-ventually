# EM::Ventually

## Background

Your tests will eventually pass. You're not sure when, but you know it'll be quick. This is where EM::Ventually can help you!

Take this trivial example. (It's in Minitest, but you can use whatever test suite you'd like*)
Without em-ventually, testing your EM code requires a lot of boilerplate such as:

~~~~~ {ruby}
    # Without em-ventually
    def test_em
     # Start EM loop.
     EM.run do
       # The only two lines you actually care about.
       val = nil
       EM.add_timer(0.5) { val = 'test' }

       # Test that work happens in the future.
       EM.add_periodic_timer(0.1) do
         if val == 'test'
           pass      # Increment assertion count.
           EM.stop   # Manually stop EM loop.
         end
       end

       # Guard against infinite loops.
       EM.add_timer(1) { raise "Potential infinite loop averted!" }
     end
    end
~~~~~

So, you want to test that val is 'test', and as well, you want EM to start on the beginning of your test and shutdown when it's done. The other thing you want is the ability to not let this test run forever, but to shutdown EM and consider it a failure if it doesn't complete.

**EM::Ventually is here to help!**

`EM::Ventually` will take care to start and stop EventMachine, and make sure your tests run serially (unless you don't want them to). It will also prevent your tests from running forever.

Taking the example above you can enqueue a test.

~~~~~ {ruby}
    def test_em
      val = 'not test'
      EM.add_timer(0.5) { val = 'test' }
      eventually('test') { val }
    end
~~~~~

This will poll the block passed to eventually every 0.1 seconds to see if the condition is equal to the argument you passed in to eventually, in this case 'test'. After one second, if it's still not equal, it will fail. If you do not pass in a value for testing, it will evaluate what you return against ruby's notion of truth (not nil and not false). An exmaple:

~~~~~ {ruby}
    def test_em
      count = 0
      EM.add_periodic_timer(0.01) { count += 0.5 }
      eventually { count >= 3 }
    end
~~~~~

As well, you can change both the polling interval as well as the maximum execution time by passing in `:every` and `:total`. Here is an example:

~~~~~ {ruby}
    def test_em
      val = nil
      EM.add_timer(0.5) { val = 'test' }
      eventually('test', :every => 0.2, :total => 10) { val } # check every 0.2 seconds
                                                              # for a total of 10 seconds.
    end
~~~~~

You can also parallelize tests if you don't want them to run serially.

~~~~~ {ruby}
    def test_em
      val1, val2 = nil, nil
      EM.add_timer(0.5) { val1 = 'test1' }
      EM.add_timer(0.5) { val2 = 'test2' }
      parallel do
        eventually('test1') { val1 }
        eventually('test2') { val2 }
      end
    end
~~~~~

Simply returning from your block doesn't always cover your test. Say for instance, you need to do a call against some sort of async client that will return your value in a callback. You can pass values back for equality by doing the following.

~~~~~ {ruby}
    class AsyncClient
      def status(&blk)
        EM.add_timer(0.5) do
          blk.call(:ok)
        end
      end
    end

    def test_em
      client = AsyncClient.new
      eventually(:ok) { |with| client.status {|status| with[status]} }
      # The secret sauce is in the arity of the block passed to `eventually`
    end
~~~~~

## Usage

Right now, `Test::Unit`, `RSpec` and `MiniTest` are supported. Just do `include EM::Ventually` in your test and you'll get all this for free. If you want to use this in all your tests, you can `require 'em-ventually/{minitest,unittest,rspec}'` your appropriate test suite.

There are a couple of global options you can mess with too. `EM::Ventually.every_default=` and `EM::Ventually.total_default=` can both set global `:every` and `:total` times for your tests.

If you don't pass a value to eventually, it will test that your value is true (in the ruby sense). Optionally, you can call `.test` to pass a custom tester.

~~~~~ {ruby}
    def test_em
      count = 0
      EM.add_periodic_timer(0.01) { count += 0.5 }
      eventually { count }.test{ |v| v >= 3 }
    end
~~~~~

of course, you're gonna be writing so many of these we've aliased it to make your tests stylish and classy.

~~~~~ {ruby}
    def test_em
      count = 0
      EM.add_periodic_timer(0.01) { count += 0.5 }
      ly { count }.test{ |v| v >= 3 }
    end
~~~~~

If you want to manually manage stopping and starting EM within a test, you can call `manually_stop_em!` within your test. An example:

~~~~~ {ruby}
    def test_em
      manually_stop_em!
      EM.add_timer(0.5) { assert "Hey!"; EM.stop }
    end
~~~~~
