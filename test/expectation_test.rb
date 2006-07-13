require 'test_helper'
require 'expectation'

class ExpectationTest < Test::Unit::TestCase
  
  def test_should_match_calls_to_same_method_with_any_parameters
    expectation = Expectation.new(:expected_method)
    assert expectation.match?(:expected_method, 1, 2, 3)
  end
  
  def test_should_match_calls_to_same_method_with_exactly_zero_parameters
    expectation = Expectation.new(:expected_method).with()
    assert expectation.match?(:expected_method)
  end
  
  def test_should_not_match_calls_to_same_method_with_more_than_zero_parameters
    expectation = Expectation.new(:expected_method).with()
    assert !expectation.match?(:expected_method, 1, 2, 3)
  end
  
  def test_should_match_calls_to_same_method_with_expected_parameter_values
    expectation = Expectation.new(:expected_method).with(1, 2, 3)
    assert expectation.match?(:expected_method, 1, 2, 3)
  end
  
  def test_should_match_calls_to_same_method_with_parameters_constrained_as_expected
    expectation = Expectation.new(:expected_method).with() {|x, y, z| x + y == z}
    assert expectation.match?(:expected_method, 1, 2, 3)
  end
  
  def test_should_not_match_calls_to_different_methods_with_no_parameters
    expectation = Expectation.new(:expected_method)
    assert !expectation.match?(:unexpected_method)
  end
  
  def test_should_not_match_calls_to_same_method_with_too_few_parameters
    expectation = Expectation.new(:expected_method).with(1, 2, 3)
    assert !expectation.match?(:unexpected_method, 1, 2)
  end
  
  def test_should_not_match_calls_to_same_method_with_too_many_parameters
    expectation = Expectation.new(:expected_method).with(1, 2)
    assert !expectation.match?(:unexpected_method, 1, 2, 3)
  end
  
  def test_should_not_match_calls_to_same_method_with_unexpected_parameter_values
    expectation = Expectation.new(:expected_method).with(1, 2, 3)
    assert !expectation.match?(:unexpected_method, 1, 0, 3)
  end
  
  def test_should_not_match_calls_to_same_method_with_parameters_not_constrained_as_expected
    expectation = Expectation.new(:expected_method).with() {|x, y, z| x + y == z}
    assert !expectation.match?(:expected_method, 1, 0, 3)
  end
  
  def test_should_return_specified_value
    expectation = Expectation.new(:expected_method).returns(99)
    assert_equal 99, expectation.invoke
  end
  
  def test_should_return_nil_if_no_value_specified
    expectation = Expectation.new(:expected_method)
    assert_nil expectation.invoke
  end
  
  def test_should_return_evaluated_proc
    expectation = Expectation.new(:expected_method).returns(lambda { 99 })
    assert_equal 99, expectation.invoke
  end
  
  def test_should_raise_runtime_exception
    expectation = Expectation.new(:expected_method).raises
    assert_raise(RuntimeError) { expectation.invoke }
  end
  
  def test_should_raise_custom_exception
    exception = Class.new(Exception)
    expectation = Expectation.new(:expected_method).raises(exception)
    assert_raise(exception) { expectation.invoke }
  end
  
  def test_should_use_the_default_exception_message
    expectation = Expectation.new(:expected_method).raises(Exception)
    exception = assert_raise(Exception) { expectation.invoke }
    assert_equal Exception.new.message, exception.message
  end
  
  def test_should_raise_custom_exception_with_message
    exception_msg = "exception message"
    expectation = Expectation.new(:expected_method).raises(Exception, exception_msg)
    exception = assert_raise(Exception) { expectation.invoke }
    assert_equal exception_msg, exception.message
  end
  
  def test_should_not_raise_error_on_verify_if_expected_call_was_made
    expectation = Expectation.new(:expected_method)
    expectation.invoke
    assert_nothing_raised(Test::Unit::AssertionFailedError) {
      expectation.verify
    }
  end
  
  def test_should_not_raise_error_on_verify_if_expected_call_was_made_at_least_once
    expectation = Expectation.new(:expected_method).at_least_once
    3.times {expectation.invoke}
    assert_nothing_raised(Test::Unit::AssertionFailedError) {
      expectation.verify
    }
  end
  
  def test_should_raise_error_on_verify_if_expected_call_was_not_made_at_least_once
    expectation = Expectation.new(:expected_method).with(1, 2, 3).at_least_once
    e = assert_raise(Test::Unit::AssertionFailedError) {
      expectation.verify
    }
    assert_match(/expected calls: at least 1, actual calls: 0/i, e.message)
  end
  
  def test_should_not_raise_error_on_verify_if_expected_call_was_made_expected_number_of_times
    expectation = Expectation.new(:expected_method).times(2)
    2.times {expectation.invoke}
    assert_nothing_raised(Test::Unit::AssertionFailedError) {
      expectation.verify
    }
  end
  
  def test_should_expect_call_not_to_be_made
    expectation = Expectation.new(:expected_method)
    expectation.define_instance_accessor(:how_many_times)
    expectation.replace_instance_method(:times) { |how_many_times| self.how_many_times = how_many_times }
    expectation.never
    assert_equal 0, expectation.how_many_times
  end
  
  def test_should_raise_error_on_verify_if_expected_call_was_made_too_few_times
    expectation = Expectation.new(:expected_method).times(2)
    1.times {expectation.invoke}
    e = assert_raise(Test::Unit::AssertionFailedError) {
      expectation.verify
    }
    assert_match(/expected calls: 2, actual calls: 1/i, e.message)
  end
  
  def test_should_raise_error_on_verify_if_expected_call_was_made_too_many_times
    expectation = Expectation.new(:expected_method).times(2)
    3.times {expectation.invoke}
    assert_raise(Test::Unit::AssertionFailedError) {
      expectation.verify
    }
  end
  
  def test_should_display_expectation_message_in_exception_message
    options = [:a, :b, {:c => 1, :d => 2}]
    expectation = Expectation.new(:expected_method).with(*options)
    exception = assert_raise(Test::Unit::AssertionFailedError) {
      expectation.verify
    }
    assert exception.message.include?(expectation.message)
  end
  
  def test_should_combine_method_name_and_pretty_parameters
    arguments = 1, 2, {'a' => true, :b => false}, [1, 2, 3]
    expectation = Expectation.new(:meth).with(*arguments)
    assert_equal ":meth(#{PrettyParameters.new(arguments).pretty})", expectation.message
  end
  
  def test_should_not_include_parameters_in_message
    expectation = Expectation.new(:meth)
    assert_equal ":meth('** any **')", expectation.message
  end
  
  def test_should_always_verify_successfully
    stub = Stub.new(:meth)
    assert stub.verify
    stub.invoke
    assert stub.verify
  end
  
end

class ExpectationSimilarExpectationsTest < Test::Unit::TestCase
  
  attr_reader :expectation
  def setup
    @expectation = Expectation.new(:meth).with(2)
  end
  
  def test_should_find_expectations_to_the_same_method
    failed_expectation = MissingExpectation.new(:meth, [expectation]).with(1)
    assert_equal [expectation], failed_expectation.similar_expectations
  end
  
  def test_should_report_similar_expectations
    missing_expectation = MissingExpectation.new(:meth, [expectation]).with(1)
    exception = assert_raise(Test::Unit::AssertionFailedError) { missing_expectation.verify }
    assert_equal "Unexpected message :meth(1)\nSimilar expectations :meth(2)", exception.message
  end
  
  def test_should_ignore_expectations_to_different_methods
    failed_expectation = MissingExpectation.new(:other_meth, [expectation]).with(1)
    assert failed_expectation.similar_expectations.empty?
  end
  
  def test_should_not_report_similar_expectations
    missing_expectation = MissingExpectation.new(:other_meth, [expectation]).with(1)
    exception = assert_raise(Test::Unit::AssertionFailedError) { missing_expectation.verify }
    assert_equal "Unexpected message :other_meth(1)", exception.message
  end
  
end