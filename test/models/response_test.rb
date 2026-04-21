require "test_helper"

class ResponseTest < ActiveSupport::TestCase
  def setup
    @participant = participants(:one)
    @slot = time_slots(:one)
  end

  test "status enum has no, maybe, yes" do
    assert_equal 0, Response.statuses[:no]
    assert_equal 1, Response.statuses[:maybe]
    assert_equal 2, Response.statuses[:yes]
  end

  test "valid with participant, time_slot, and status" do
    r = Response.new(participant: participants(:two), time_slot: @slot, status: :yes)
    assert r.valid?
  end

  test "requires status" do
    r = Response.new(participant: participants(:two), time_slot: @slot)
    r.status = nil
    assert_not r.valid?
    assert_includes r.errors[:status], "can't be blank"
  end

  test "enforces uniqueness of participant + time_slot" do
    existing = responses(:one)
    dup = Response.new(participant: existing.participant, time_slot: existing.time_slot, status: :no)
    assert_not dup.valid?
  end

  test "yes? helper works" do
    r = Response.new(status: :yes)
    assert r.yes?
    assert_not r.no?
  end

  test "upsert_for creates or updates" do
    participant = participants(:two)
    slot = time_slots(:one)
    Response.upsert_for(participant: participant, time_slot: slot, status: :yes)
    r = Response.find_by(participant: participant, time_slot: slot)
    assert_not_nil r
    assert r.yes?

    Response.upsert_for(participant: participant, time_slot: slot, status: :no)
    assert r.reload.no?
  end
end
