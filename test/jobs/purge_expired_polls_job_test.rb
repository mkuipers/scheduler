require "test_helper"

class PurgeExpiredPollsJobTest < ActiveJob::TestCase
  test "deletes polls whose expires_at is in the past" do
    expired = Poll.create!(creator_name: "A", creator_cookie_id: "c1",
                           expires_at: 1.day.ago)
    active  = Poll.create!(creator_name: "B", creator_cookie_id: "c2",
                           expires_at: 1.day.from_now)

    PurgeExpiredPollsJob.new.perform

    assert_raises(ActiveRecord::RecordNotFound) { expired.reload }
    assert_nothing_raised { active.reload }
  end

  test "cascades deletion to time_slots and participants" do
    expired = Poll.create!(creator_name: "A", creator_cookie_id: "cx", expires_at: 1.day.ago)
    slot = TimeSlot.create!(poll: expired, date: "2026-05-01", starts_at_minute: 840, ends_at_minute: 960)
    participant = Participant.create!(poll: expired, name: "Eve", cookie_id: "cy")
    Response.create!(participant: participant, time_slot: slot, status: :yes)

    assert_difference ["TimeSlot.count", "Participant.count", "Response.count"], -1 do
      PurgeExpiredPollsJob.new.perform
    end
  end

  test "does not delete polls expiring exactly now" do
    freeze_time do
      poll = Poll.create!(creator_name: "A", creator_cookie_id: "c1", expires_at: Time.current)
      PurgeExpiredPollsJob.new.perform
      assert_nothing_raised { poll.reload }
    end
  end
end
