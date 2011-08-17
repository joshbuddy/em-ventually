require 'bundler/gem_tasks'

task :default => :test
task :test => [:'test:readme', :'test:suites']

namespace :test do
  task :suites do
    matchers = {
      'minitest-2.0' => [/6 tests, 9 assertions, 1 failures, 0 errors/m],
      'rspec-2.6' => [/\n\.\.\.\.F\.\.\.\n/m],
      'test-unit' => [/\n\.\.\.F\.\.\n/m, /test_out_of_order\(TestEMVentually\)/m]
    }

    matchers.each do |type, matcher|
      STDOUT.sync = true
      Dir.chdir("./test/#{type}") do
        print "Testing #{type}#{' ' * (22 - type.size )}"
        fork {
          ENV['BUNDLE_GEMFILE'] = File.expand_path("./Gemfile")
          out = `bundle && bundle exec rake 2>&1`
          if matcher.all?{|m|out[m]}
            exit
          else
            puts out
            exit 1
          end
        }
        _, status = Process.wait2
        puts status.success? ? "PASSED" : "FAILED"
      end
    end
  end

  task :readme do
    # test README.md
    puts "Testing README.md"
    STDOUT.sync = true
    readme = File.read('./README.md')
    passes = readme.scan(/~~~~~ \{ruby\}\n(.*?)~~~~~/m).map do |block|
      fork {
        require 'minitest/autorun'
        require 'eventmachine'
        $LOAD_PATH << 'lib'
        STDOUT.reopen('/dev/null')
        require 'em-ventually'
        code = block.join
        cls = Class.new(MiniTest::Unit::TestCase)
        cls.class_eval "include EM::Ventually" unless code[/# Without em-ventually/]
        cls.class_eval(code)
        cls
      }
      _, status = Process.wait2
      print status.success? ? '.' : 'F'
      status.success? ? :pass : :fail
    end
    puts
    pass_count = passes.inject(0){|m, s| m += (s == :pass ? 1 : 0)}
    raise "README tests failed" unless pass_count == passes.size
  end
end