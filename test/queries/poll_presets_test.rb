require "test_helper"

class PollPresetsTest < ActiveSupport::TestCase
  test "returns distinct time windows in creation order" do
    poll = polls(:one)
    # fixtures: one 840-960, two 540-660, three 600-660 (same poll, distinct windows; order follows query)
    presets = PollPresets.new(poll).call
    assert_equal 3, presets.length
    assert_equal [[540, 660], [600, 660], [840, 960]], presets
    assert presets.all? { |s, e| e > s }
  end

  test "returns unique windows even when same window used on multiple dates" do
    poll = polls(:two)
    travel_to Time.zone.local(2026, 5, 1) do
      TimeSlot.create!(poll: poll, date: "2026-06-01", starts_at_minute: 840, ends_at_minute: 960)
    end
    travel_to Time.zone.local(2026, 5, 2) do
      TimeSlot.create!(poll: poll, date: "2026-06-02", starts_at_minute: 840, ends_at_minute: 960)
      TimeSlot.create!(poll: poll, date: "2026-06-02", starts_at_minute: 600, ends_at_minute: 720)
    end

    presets = PollPresets.new(poll).call
    assert_equal 2, presets.length
    assert_equal [840, 960], presets.first
    assert_equal [600, 720], presets.last
  end

  test "returns empty array when poll has no time slots" do
    poll = Poll.create!(creator_name: "X", creator_cookie_id: "c")
    assert_empty PollPresets.new(poll).call
  end

  test "does not bleed across polls" do
    poll1 = polls(:one)
    poll2 = polls(:two)
    TimeSlot.create!(poll: poll2, date: "2026-07-01", starts_at_minute: 300, ends_at_minute: 360)

    presets1 = PollPresets.new(poll1).call
    assert presets1.none? { |s, _| s == 300 }
  end
end
