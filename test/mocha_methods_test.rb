require 'test_helper'
require 'mocha_methods'

class MochaMethodsTest < Test::Unit::TestCase
  
  def test_should_create_and_add_expectations
    mock = Object.new
    mock.extend(MochaMethods)
    
    expectation1 = mock.expects(:method1)
    expectation2 = mock.expects(:method2)
    
    assert_equal [expectation1, expectation2].to_set, mock.expectations.to_set
  end
  
  def test_should_create_and_add_stubs
    mock = Object.new
    mock.extend(MochaMethods)
    
    stub1 = mock.stubs(:method1)
    stub2 = mock.stubs(:method2)
    
    assert_equal [stub1, stub2].to_set, mock.expectations.to_set
  end
  
  def test_should_find_matching_expectation
    mock = Object.new
    mock.extend(MochaMethods)

    expectation1 = mock.expects(:my_method).with(:argument1, :argument2)
    expectation2 = mock.expects(:my_method).with(:argument3, :argument4)
    
    assert_equal expectation2, mock.matching_expectation(:my_method, :argument3, :argument4)
  end
  
  def test_should_invoke_expectation_and_return_result
    mock = Object.new
    mock.extend(MochaMethods)
    mock.expects(:my_method).returns(:result)
    
    result = mock.my_method
    
    assert_equal :result, result
  end
  
  def test_should_raise_no_method_error
    mock = Object.new
    mock.extend(MochaMethods)
    assert_raise(NoMethodError) do
      mock.super_method_missing(nil)
    end
  end
  
  def test_should_raise_assertion_error_for_unexpected_method_call
    mock = Object.new
    mock.extend(MochaMethods)
    error = assert_raise(Test::Unit::AssertionFailedError) do
      mock.unexpected_method_called(:my_method, :argument1, :argument2)
    end
    assert_match /my_method/, error.message
    assert_match /argument1/, error.message
    assert_match /argument2/, error.message
  end
  
  def test_should_indicate_unexpected_method_called
    mock = Object.new
    mock.extend(MochaMethods)
    class << mock
      attr_accessor :symbol, :arguments
      def unexpected_method_called(symbol, *arguments)
        self.symbol, self.arguments = symbol, arguments
      end
    end
    mock.my_method(:argument1, :argument2)

    assert_equal :my_method, mock.symbol
    assert_equal [:argument1, :argument2], mock.arguments
  end
  
  def test_should_call_method_missing_for_parent
    mock = Object.new
    mock.extend(MochaMethods)
    class << mock
      attr_accessor :symbol, :arguments
      def super_method_missing(symbol, *arguments, &block)
        self.symbol, self.arguments = symbol, arguments
      end
    end
    
    mock.my_method(:argument1, :argument2)
    
    assert_equal :my_method, mock.symbol
    assert_equal [:argument1, :argument2], mock.arguments
  end
  
  def test_should_verify_that_all_expectations_have_been_fulfilled
    mock = Object.new
    mock.extend(MochaMethods)
    mock.expects(:method1)
    mock.expects(:method2)
    mock.method1
    assert_raise(Test::Unit::AssertionFailedError) do
      mock.verify
    end
  end
  
  def test_should_only_verify_expectations_matching_method_name
    mock = Object.new
    mock.extend(MochaMethods)
    mock.expects(:method1)
    mock.expects(:method2)
    mock.method1
    assert_nothing_raised(Test::Unit::AssertionFailedError) do
      mock.verify(:method1)
    end
    assert_raise(Test::Unit::AssertionFailedError) do
      mock.verify(:method2)
    end
  end
  
  def test_should_only_verify_expectations_matching_multiple_method_names
    mock = Object.new
    mock.extend(MochaMethods)
    mock.expects(:method1)
    mock.expects(:method2)
    assert_raise(Test::Unit::AssertionFailedError) do
      mock.verify(:method1, :method2)
    end
  end
  
  def test_should_report_possible_expectations
    mock = Object.new.extend(MochaMethods)
    mock.expects(:meth).with(1)
    exception = assert_raise(Test::Unit::AssertionFailedError) { mock.meth(2) }
    assert_equal "Unexpected message :meth(2)\nSimilar expectations :meth(1)", exception.message
  end
  
end