require "test_helper"

class PollTest < ActiveSupport::TestCase
  test "auto-generates a url-safe token before create" do
    poll = Poll.create!(creator_name: "Alice", creator_cookie_id: "abc")
    assert_not_nil poll.token
    assert_match(/\A[A-Za-z0-9_\-]+\z/, poll.token)
    assert poll.token.length >= 8
  end

  test "tokens are unique across polls" do
    p1 = Poll.create!(creator_name: "Alice", creator_cookie_id: "c1")
    p2 = Poll.create!(creator_name: "Bob",   creator_cookie_id: "c2")
    assert_not_equal p1.token, p2.token
  end

  test "sets expires_at to 180 days from creation" do
    freeze_time do
      poll = Poll.create!(creator_name: "Alice", creator_cookie_id: "abc")
      assert_in_delta 180.days.from_now.to_i, poll.expires_at.to_i, 1
    end
  end

  test "requires creator_name" do
    poll = Poll.new(creator_cookie_id: "abc")
    assert_not poll.valid?
    assert_includes poll.errors[:creator_name], "can't be blank"
  end

  test "requires creator_cookie_id" do
    poll = Poll.new(creator_name: "Alice")
    assert_not poll.valid?
    assert_includes poll.errors[:creator_cookie_id], "can't be blank"
  end

  test "creator? returns true when cookie matches" do
    poll = polls(:one)
    assert poll.creator?("cookie_creator_one")
  end

  test "creator? returns false when cookie does not match" do
    poll = polls(:one)
    assert_not poll.creator?("some_other_cookie")
  end

  test "destroying a poll cascades to time_slots and participants" do
    poll = polls(:one)
    assert_difference ["TimeSlot.count", "Participant.count"], -2 do
      assert_difference "Response.count", -2 do
        poll.destroy!
      end
    end
  end
end
