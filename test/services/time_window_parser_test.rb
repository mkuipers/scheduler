require "test_helper"

class TimeWindowParserTest < ActiveSupport::TestCase
  # -- Happy paths ----------------------------------------------------------

  test "parses simple am/pm range" do
    result = TimeWindowParser.parse("2pm-4pm")
    assert result.ok?
    assert_equal 14 * 60, result.start_minute  # 840
    assert_equal 16 * 60, result.end_minute    # 960
  end

  test "parses range with minutes" do
    result = TimeWindowParser.parse("2:30pm-4:15pm")
    assert result.ok?
    assert_equal 14 * 60 + 30, result.start_minute
    assert_equal 16 * 60 + 15, result.end_minute
  end

  test "parses compact meridiem without colon e.g. 330pm" do
    result = TimeWindowParser.parse("330pm-5pm")
    assert result.ok?
    assert_equal 15 * 60 + 30, result.start_minute
    assert_equal 17 * 60, result.end_minute
  end

  test "parses compact meridiem with space before am/pm" do
    result = TimeWindowParser.parse("930 am - 10 am")
    assert result.ok?
    assert_equal 9 * 60 + 30, result.start_minute
    assert_equal 10 * 60, result.end_minute
  end

  test "parses four-digit compact e.g. 1030am" do
    result = TimeWindowParser.parse("1030am-12pm")
    assert result.ok?
    assert_equal 10 * 60 + 30, result.start_minute
    assert_equal 12 * 60, result.end_minute
  end

  test "does not mangle already-colon times" do
    result = TimeWindowParser.parse("2:30pm-4pm")
    assert result.ok?
    assert_equal 14 * 60 + 30, result.start_minute
  end

  test "parses 24-hour format" do
    result = TimeWindowParser.parse("14:00-16:00")
    assert result.ok?
    assert_equal 840, result.start_minute
    assert_equal 960, result.end_minute
  end

  test "parses 'to' separator" do
    result = TimeWindowParser.parse("9am to 10am")
    assert result.ok?
    assert_equal 9 * 60, result.start_minute
    assert_equal 10 * 60, result.end_minute
  end

  test "inherits am/pm suffix for start when end has it" do
    result = TimeWindowParser.parse("9-10am")
    assert result.ok?
    assert_equal 9 * 60, result.start_minute
    assert_equal 10 * 60, result.end_minute
  end

  test "inherits pm suffix for start when end has pm" do
    result = TimeWindowParser.parse("2-4pm")
    assert result.ok?
    assert_equal 14 * 60, result.start_minute
    assert_equal 16 * 60, result.end_minute
  end

  test "handles leading/trailing whitespace" do
    result = TimeWindowParser.parse("  9am - 11am  ")
    assert result.ok?
    assert_equal 9 * 60, result.start_minute
    assert_equal 11 * 60, result.end_minute
  end

  test "handles en-dash separator" do
    result = TimeWindowParser.parse("2pm–4pm")
    assert result.ok?
    assert_equal 14 * 60, result.start_minute
    assert_equal 16 * 60, result.end_minute
  end

  test "parses midnight and noon correctly" do
    result = TimeWindowParser.parse("12pm-1pm")
    assert result.ok?
    assert_equal 12 * 60, result.start_minute
    assert_equal 13 * 60, result.end_minute
  end

  test "parses 12am as midnight" do
    result = TimeWindowParser.parse("12am-1am")
    assert result.ok?
    assert_equal 0, result.start_minute
    assert_equal 60, result.end_minute
  end

  # -- Rejection cases -------------------------------------------------------

  test "rejects empty string" do
    result = TimeWindowParser.parse("")
    assert_not result.ok?
    assert_not_nil result.error
  end

  test "rejects garbage" do
    result = TimeWindowParser.parse("whenever")
    assert_not result.ok?
  end

  test "rejects reversed range" do
    result = TimeWindowParser.parse("4pm-2pm")
    assert_not result.ok?
    assert_match(/after/, result.error)
  end

  test "rejects same start and end" do
    result = TimeWindowParser.parse("3pm-3pm")
    assert_not result.ok?
  end

  test "rejects hour > 23 in 24h format" do
    result = TimeWindowParser.parse("25:00-26:00")
    assert_not result.ok?
  end

  test "rejects minute > 59" do
    result = TimeWindowParser.parse("2:60pm-4:00pm")
    assert_not result.ok?
  end

  test "rejects single time" do
    result = TimeWindowParser.parse("2pm")
    assert_not result.ok?
  end
end
