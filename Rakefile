require 'bundler/gem_tasks'

task :default => :test

task :test do
  matchers = {
    'minitest-2.0' => [/6 tests, 9 assertions, 1 failures, 0 errors, 0 skips/m],
    'rspec-2.6' => [/\n\.\.\.\.F\.\n/m],
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

