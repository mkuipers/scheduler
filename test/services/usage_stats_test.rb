require "test_helper"

class UsageStatsTest < ActiveSupport::TestCase
  test "aggregate returns fourteen day series" do
    stats = UsageStats.new.aggregate
    assert_equal Poll.count, stats.total_polls
    assert_equal Response.count, stats.total_responses
    assert_equal UsageStats::CHART_DAYS, stats.polls_by_day.length
    assert_equal UsageStats::CHART_DAYS, stats.responses_by_day.length
    assert stats.polls_by_day.all? { |row| row[:date].is_a?(Date) }
    assert stats.polls_by_day.sum { |row| row[:count] } <= Poll.count
  end
end
