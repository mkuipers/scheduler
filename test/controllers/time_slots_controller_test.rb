require "test_helper"

class TimeSlotsControllerTest < ActionDispatch::IntegrationTest
  def setup
    get new_poll_url
    post polls_url, params: { poll: { creator_name: "Alice" } }
    @poll = Poll.last
  end

  test "POST creates slot via free-form time window" do
    assert_difference "TimeSlot.count" do
      post poll_time_slots_url(@poll.token),
           params: { time_slot: { date: "2026-06-01", time_window: "2pm-4pm" } }
    end
    slot = TimeSlot.last
    assert_equal 14 * 60, slot.starts_at_minute
    assert_equal 16 * 60, slot.ends_at_minute
    assert_redirected_to poll_url(@poll.token, calendar_month: "2026-06")
  end

  test "POST creates slot via preset (direct minutes)" do
    assert_difference "TimeSlot.count" do
      post poll_time_slots_url(@poll.token),
           params: { time_slot: { date: "2026-06-02", starts_at_minute: 540, ends_at_minute: 660 } }
    end
    assert_redirected_to poll_url(@poll.token, calendar_month: "2026-06")
  end

  test "POST with unparseable time_window returns 422" do
    assert_no_difference "TimeSlot.count" do
      post poll_time_slots_url(@poll.token),
           params: { time_slot: { date: "2026-06-01", time_window: "not a time" } }
    end
    assert_response :unprocessable_entity
  end

  test "POST with reversed range returns 422" do
    assert_no_difference "TimeSlot.count" do
      post poll_time_slots_url(@poll.token),
           params: { time_slot: { date: "2026-06-01", time_window: "4pm-2pm" } }
    end
    assert_response :unprocessable_entity
  end

  test "POST duplicate window on same date returns 422" do
    post poll_time_slots_url(@poll.token),
         params: { time_slot: { date: "2026-06-01", time_window: "2pm-4pm" } }
    assert_response :redirect

    assert_no_difference "TimeSlot.count" do
      post poll_time_slots_url(@poll.token),
           params: { time_slot: { date: "2026-06-01", time_window: "2pm-4pm" } }
    end
    assert_response :unprocessable_entity
    assert_match(/already an option/i, response.body)
  end

  test "DELETE removes time slot as creator" do
    slot = TimeSlot.create!(poll: @poll, date: "2026-06-01", starts_at_minute: 840, ends_at_minute: 960)
    assert_difference "TimeSlot.count", -1 do
      delete poll_time_slot_url(@poll.token, slot)
    end
    assert_redirected_to poll_url(@poll.token, calendar_month: "2026-06")
  end

  test "DELETE as non-creator returns 404" do
    slot = time_slots(:one)  # belongs to polls(:one), not @poll
    assert_no_difference "TimeSlot.count" do
      delete poll_time_slot_url(polls(:one).token, slot)
    end
    assert_response :not_found
  end

  test "POST as non-creator returns 404" do
    get new_poll_url  # fresh session — new cookie
    # Use another session (different cookie) to try to add slot to @poll
    other_poll_token = polls(:one).token
    assert_no_difference "TimeSlot.count" do
      post poll_time_slots_url(other_poll_token),
           params: { time_slot: { date: "2026-06-01", time_window: "2pm-4pm" } }
    end
    assert_response :not_found
  end
end
