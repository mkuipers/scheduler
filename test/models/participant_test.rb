require "test_helper"

class ParticipantTest < ActiveSupport::TestCase
  def setup
    @poll = polls(:one)
  end

  test "valid with name and cookie_id" do
    p = Participant.new(poll: @poll, name: "Eve", cookie_id: "unique_cookie_999")
    assert p.valid?
  end

  test "requires name" do
    p = Participant.new(poll: @poll, cookie_id: "c123")
    assert_not p.valid?
    assert_includes p.errors[:name], "can't be blank"
  end

  test "requires cookie_id" do
    p = Participant.new(poll: @poll, name: "Eve")
    assert_not p.valid?
    assert_includes p.errors[:cookie_id], "can't be blank"
  end

  test "enforces uniqueness of cookie_id per poll" do
    Participant.create!(poll: @poll, name: "First", cookie_id: "dup_cookie")
    dup = Participant.new(poll: @poll, name: "Second", cookie_id: "dup_cookie")
    assert_not dup.valid?
  end

  test "same cookie_id allowed on different polls" do
    poll2 = polls(:two)
    Participant.create!(poll: @poll,  name: "First",  cookie_id: "shared_cookie")
    other = Participant.new(poll: poll2, name: "Second", cookie_id: "shared_cookie")
    assert other.valid?
  end

  test "destroying a participant cascades to responses" do
    participant = participants(:one)
    response_count = participant.responses.count
    assert_difference "Response.count", -response_count do
      participant.destroy!
    end
  end
end
