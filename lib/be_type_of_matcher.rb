#
# Rspec be_type_of matcher
#
# Or pattern
#   # assert the value is a String or Symbol
#     # rspec build-in matcher
#     expect(:foo).to be_kind_of(String).or be_kind_of(Symnbol)
#
#     # ↓
#     expect("foo").to be_type_of(String, Symnbol)
#     expect(:foo).to be_type_of(String, Symnbol)
#     => ok
#
#     expect(1).to be_type_of(String, Symnbol)
#     => fali
#
# Allow nil value
#   # assert the value is a String or nil
#     # rspec built-in matcher
#     expect(:foo).to be_nil.or be_kind_of(String)
#
#     # ↓
#     expect("foo").to be_type_of(String).or_nil
#     expect(nil).to be_type_of(String).or_nil
#     => ok
#
# TrueClass/FalseClass
#   # assert the value is a boolean
#     expect(true).to be_type_of(:boolean)
#     => ok
#
#     expect(:foo).to be_type_of(:boolean)
#     => false
#
# Array pattern
#
#   # assert the value is a Array of String
#     # rspec built-in matcher
#     expect(["foo", "bar"]).to all(be_type_of(String))
#     => ok
#
#     # ↓
#     expect(["foo", :bar]).to be_type_of([String])
#       => fail
#
#   # Array pattern must exactly 1 value
#     expect(["foo", :bar]).to be_type_of([String, Symbol])
#       => error
#
#   # assert the value is a Array of (String or Symbol)
#     # rspec built-in matcher
#     expect(["foo", :bar]).to all(be_kind_of(String).or be_kind_of(Symbol))
#
#     # ↓
#     expect(["foo", :bar]).to be_type_of([be_type_of(String, Symbol)])
#       => ok
#
# Hash pattern
#   # assert the value is a Hash those key is Symbol and value is String
#     # rspec built-in matcher
#     expect({foo: "aaa"}.keys).to all(be_kind_of(Symbol))
#     expect({foo: "aaa"}.values).to all(be_kind_of(String))
#
#     # ↓
#     expect({foo: "aaa"}).to be_type_of(Symbol => String)
#       => ok
#     expect({foo: "aaa", bar: :bbb}).to be_type_of(Symbol => String)
#       => fail
#
#   # Hash pattern must exactly 1 entry
#     expect({foo: "aaa"}).to be_type_of(Symbol => String, Integer => String)
#       => error
#
#   # with composit matcher on values
#     expect({foo: "aaa", bar: 1}).to be_type_of(Symbol => be_type_of(Symbol, Integer))
#       => ok
#
#   # with composit matcher on key and values
#     expect({foo: "aaa", "bar" => 1}).to be_type_of(
#       be_type_of( be_type_of(String, Symbol)=> be_type_of(Symbol, Integer)
#     )
#       => ok
#
module BeTypeOfMatcher
  class InvalidTypeDefinitionError < StandardError; end

  def or_match?(expected_types, actual, or_nil)
    return true if expected_types.any?{|expected_type| match?(expected_type, actual, @or_nil) }

    expected_types.length > 1 ?
      fail_with(actual, expected_types.join(" or "), or_nil) :
      false
  end

  def match?(expected_type, actual, or_nil)
    if or_nil && actual.nil?
      return true
    end

    if expected_type == :boolean
      return boolean_match?(actual)
    end

    if Hash === expected_type
      return hashes_match?(expected_type, actual, or_nil)
    end

    if Array === expected_type
      return values_match?(expected_type, actual, or_nil)
    end

    if RSpec::Matchers.is_a_matcher?(expected_type)
      return matcher_match?(expected_type, actual, or_nil)
    end

    if expected_type.is_a?(Module)
      return type_match?(expected_type, actual, or_nil)
    end

    fail_with(actual, expected_type, or_nil)
  end

  def fail_with_message(message)
    if @failure_message
      message += "\n  (#{@failure_message})"
    end

    @failure_message = message
    false
  end

  def fail_with(actual, expected_type, or_nil)
    msg = "expected #{actual.inspect} to be type of #{expected_type.inspect}"
    msg += " or nil" if or_nil
    fail_with_message(msg)
  end

  def is_array_type?(actual)
    Enumerable === actual && !(Struct === actual)
  end

  def boolean_match?(actual)
    return true if actual.is_a?(TrueClass) || actual.is_a?(FalseClass)

    fail_with_message("expected #{actual.inspect} to be type of :boolean")
  end

  def hashes_match?(expected_type, actual, or_nil)
    if expected_type.size > 1
      return fail_with_message("[be_type_of matcher] expcted type of hash must have exactly 1 entry, but given #{expected_type.inspect}")
    end

    unless actual.is_a?(Hash)
      return fail_with(actual, expected_type, or_nil)
    end

    key_type, value_type = expected_type.first
    valid = actual.all?{|key, val|
      match?(key_type, key, or_nil) && match?(value_type, val, or_nil)
    }

    unless valid
      return fail_with(actual, expected_type, or_nil)
    end

    true
  end

  def values_match?(expected_type, actual, or_nil)
    if expected_type.size > 1
      return fail_with_message("[be_type_of matcher] expcted type of array must have exactly 1 element, but given #{expected_type.inspect}")
    end

    unless is_array_type?(actual)
      return fail_with(actual, expected_type, or_nil)
    end

    value_type = expected_type.first
    unless actual.all?{|val| match?(value_type, val, or_nil) }
      return fail_with(actual, expected_type, or_nil)
    end

    true
  end

  def matcher_match?(expected_type, actual, or_nil)
    matcher = expected_type.clone
    return true if matcher.matches?(actual)

    fail_with_message(matcher.failure_message)
  end

  def type_match?(expected_type, actual, or_nil)
    return true if actual.is_a?(expected_type)

    fail_with(actual, expected_type, or_nil)
  end
end

RSpec::Matchers.define(:be_type_of) {|*expected_types|
  include BeTypeOfMatcher

  match {|actual|
    or_match?(expected_types, actual, @or_nil)
  }

  chain(:or_nil) {
    @or_nil = true
  }

  description {
    "be type of #{expected_types.join(" or ") }#{@or_nil ? "or nil" : "" }"
  }

  failure_message {|_val|
    @failure_message
  }
}
