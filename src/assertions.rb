module Assertions

  def assert_equals(expected, actual)
    unless expected==actual
      raise AssertionError,
            "expected value #{expected} but was #{actual}"
    end
  end
end

class AssertionError < StandardError;
end