require "test_helper"

class TimeSlotTest < ActiveSupport::TestCase
  def setup
    @poll = polls(:one)
  end

  test "valid with all required fields" do
    slot = TimeSlot.new(poll: @poll, date: "2026-06-01", starts_at_minute: 840, ends_at_minute: 960)
    assert slot.valid?
  end

  test "requires date" do
    slot = TimeSlot.new(poll: @poll, starts_at_minute: 840, ends_at_minute: 960)
    assert_not slot.valid?
    assert_includes slot.errors[:date], "can't be blank"
  end

  test "requires starts_at_minute" do
    slot = TimeSlot.new(poll: @poll, date: "2026-06-01", ends_at_minute: 960)
    assert_not slot.valid?
  end

  test "requires ends_at_minute" do
    slot = TimeSlot.new(poll: @poll, date: "2026-06-01", starts_at_minute: 840)
    assert_not slot.valid?
  end

  test "rejects inverted range" do
    slot = TimeSlot.new(poll: @poll, date: "2026-06-01", starts_at_minute: 960, ends_at_minute: 840)
    assert_not slot.valid?
    assert_includes slot.errors[:ends_at_minute], "must be after start time"
  end

  test "rejects equal start and end" do
    slot = TimeSlot.new(poll: @poll, date: "2026-06-01", starts_at_minute: 840, ends_at_minute: 840)
    assert_not slot.valid?
  end

  test "rejects duplicate date+window on same poll" do
    TimeSlot.create!(poll: @poll, date: "2026-06-01", starts_at_minute: 840, ends_at_minute: 960)
    dup = TimeSlot.new(poll: @poll, date: "2026-06-01", starts_at_minute: 840, ends_at_minute: 960)
    assert_not dup.valid?
    assert_includes dup.errors[:base], "That exact time is already an option on this date."
  end

  test "allows same window on different dates" do
    TimeSlot.create!(poll: @poll, date: "2026-06-01", starts_at_minute: 840, ends_at_minute: 960)
    slot = TimeSlot.new(poll: @poll, date: "2026-06-02", starts_at_minute: 840, ends_at_minute: 960)
    assert slot.valid?
  end

  test "display_label formats whole hours" do
    slot = TimeSlot.new(starts_at_minute: 14 * 60, ends_at_minute: 16 * 60)
    assert_equal "2:00pm \u2013 4:00pm", slot.display_label
  end

  test "display_label formats minutes" do
    slot = TimeSlot.new(starts_at_minute: 14 * 60 + 30, ends_at_minute: 16 * 60 + 15)
    assert_equal "2:30pm \u2013 4:15pm", slot.display_label
  end

  test "display_label uses am for morning times" do
    slot = TimeSlot.new(starts_at_minute: 9 * 60, ends_at_minute: 10 * 60)
    assert_equal "9:00am \u2013 10:00am", slot.display_label
  end

  test "display_label handles noon" do
    slot = TimeSlot.new(starts_at_minute: 12 * 60, ends_at_minute: 13 * 60)
    assert_equal "12:00pm \u2013 1:00pm", slot.display_label
  end

  test "display_label handles midnight start" do
    slot = TimeSlot.new(starts_at_minute: 0, ends_at_minute: 60)
    assert_equal "12:00am \u2013 1:00am", slot.display_label
  end

  test "ordered_by_date scope sorts ascending" do
    slots = TimeSlot.ordered_by_date.pluck(:date)
    assert_equal slots.sort, slots
  end
end
