require 'test_helper'
require 'rugui/log_support'

class TestLogSupport < Test::Unit::TestCase
  include RuGUI::LogSupport

  def test_should_create_a_default_logger_if_it_wasnt_initialized
    assert_not_nil(logger)
  end

  def test_should_create_a_custom_logger_if_it_was_initialized
    initialize_logger
    assert_not_nil(@logger)
  end
end
