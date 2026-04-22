require "test_helper"

class UsageStatsControllerTest < ActionDispatch::IntegrationTest
  test "index is public" do
    get usage_stats_url
    assert_response :success
    assert_select "h1", /Usage stats/i
    assert_select ".stats-summary"
    assert_select ".bar-chart"
  end
end
