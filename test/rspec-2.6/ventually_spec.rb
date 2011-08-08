$LOAD_PATH << "#{File.dirname(__FILE__)}/../../lib"
require 'em-ventually/rspec'


describe EM::Ventually do
  include EM::Ventually

  it "should allow a normal test" do
    1.should == 1
  end

  it "should allow a simple em test" do
    val = nil
    EM.add_timer(0.5) { val = 'test' }
    eventually('test') { val }
  end

  it "should allow an em test with value passing" do
    val = nil
    EM.add_timer(0.5) { val = 'test' }
    eventually('test') {|m| m[val] }
  end

  it "should allow multiple eventuallys" do
    val = nil
    EM.add_timer(0.3) { val = 'test' }
    EM.add_timer(0.8) { val = 'test2' }
    eventually('test') {|m| m[val] }
    eventually('test2') {|m| m[val] }
  end

  it "should fail when out of order" do
    val = nil
    EM.add_timer(0.3) { val = 'test2' }
    EM.add_timer(0.8) { val = 'test' }
    eventually('test') {|m| m[val] }
    eventually('test2') {|m| m[val] }
  end

  it "should succeed when out of order using parallel" do
    val = nil
    EM.add_timer(0.3) { val = 'test2' }
    EM.add_timer(0.8) { val = 'test' }
    parallel {
      eventually('test') {|m| m[val] }
      eventually('test2') {|m| m[val] }
    }
  end

  it "should allow longer tests with a specific number of passes" do
    val = nil
    count = 0
    EM.add_timer(3.1) { val = 'done'}
    eventually('done', :every => 0.5, :total => 3.5) { count +=1; val }
    eventually(7) { count }
  end
end