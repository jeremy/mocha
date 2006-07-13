require 'test_helper'
require 'stubba'
require 'mocha'

class StubbaTest < Test::Unit::TestCase
  
  def test_should_start_with_empty_stubba_methods
    stubba = Stubba.new
    
    assert_equal [], stubba.stubba_methods
  end
  
  def test_should_stub_method_if_not_already_stubbed
    method = Mocha.new
    method.expects(:stub)
    stubba = Stubba.new
    
    stubba.stub(method)
    
    method.verify
  end
  
  def test_should_not_stub_method_if_already_stubbed
    method = Mocha.new
    method.expects(:stub).times(0)
    stubba = Stubba.new
    stubba_methods = Mocha.new
    stubba_methods.stubs(:include?).with(method).returns(true)
    stubba.stubba_methods = stubba_methods
    
    stubba.stub(method)
    
    method.verify
  end
  
  def test_should_record_method
    method = Mocha.new
    method.expects(:stub)
    stubba = Stubba.new
    
    stubba.stub(method)
    
    assert_equal [method], stubba.stubba_methods
  end
  
  def test_should_unstub_all_methods
    stubba = Stubba.new
    method_1 = Mocha.new(:unstub => nil)
    method_2 = Mocha.new(:unstub => nil)
    stubba.stubba_methods = [method_1, method_2]

    stubba.unstub_all
    
    assert_equal [], stubba.stubba_methods
    method_1.verify
    method_2.verify
  end

end
