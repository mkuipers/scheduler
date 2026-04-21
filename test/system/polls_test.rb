require "application_system_test_case"

class PollsTest < ApplicationSystemTestCase
  test "creator flow: create poll and add a time slot" do
    travel_to Time.zone.local(2026, 4, 21, 12, 0, 0) do
      visit "/scheduler"
      assert_selector "h1", text: "Schedule a meeting"

      fill_in "Your name", with: "Alice"
      fill_in "Meeting title (optional)", with: "Team standup"
      click_on "Get started"

      assert_text(/share link/i)
      assert_selector "button[aria-label='Next month']", wait: 10
      3.times { find("button[aria-label='Next month']").click }
      find(%q([data-iso="2026-07-01"])).click
      assert_selector "dialog.slot-modal[open]", wait: 10
      within(".slot-modal__panel") do
        find("#slot_form_custom_time_window", visible: :all).set("9am-10am")
      end
      click_on "Add time slot"

      assert_text "9:00am \u2013 10:00am"
      assert_text "July 1, 2026"
    end
  end

  test "creator can remove a time slot" do
    travel_to Time.zone.local(2026, 4, 21, 12, 0, 0) do
      visit "/scheduler"
      fill_in "Your name", with: "Bob"
      click_on "Get started"

      assert_text(/share link/i)
      assert_selector "button[aria-label='Next month']", wait: 10
      4.times { find("button[aria-label='Next month']").click }
      find(%q([data-iso="2026-08-15"])).click
      assert_selector "dialog.slot-modal[open]", wait: 10
      within(".slot-modal__panel") do
        find("#slot_form_custom_time_window", visible: :all).set("2pm-4pm")
      end
      click_on "Add time slot"
      assert_text "August 15, 2026"

      click_on "Remove"
      assert_no_text "August 15, 2026"
    end
  end

  test "voter flow: enter name and submit responses" do
    poll = polls(:one)
    visit poll_url(poll.token)

    assert_selector "h2", text: "Join this poll"
    fill_in "Your name", with: "Charlie"
    click_on "Join poll"

    assert_selector "h2", text: /Your availability, Charlie/
    choose "yes_#{time_slots(:one).id}"
    choose "maybe_#{time_slots(:two).id}"
    click_on "Save my availability"

    assert_text "Availability saved!"
  end

  test "voter can decline all slots for one day" do
    poll = polls(:one)
    visit poll_url(poll.token)
    fill_in "Your name", with: "Eve"
    click_on "Join poll"

    within(find(".availability-day-group", text: "Sunday, May 10, 2026")) do
      click_on "Decline all this day"
    end

    assert page.has_checked_field?("no_#{time_slots(:one).id}", visible: :all)
    assert page.has_checked_field?("no_#{time_slots(:three).id}", visible: :all)
    refute page.has_checked_field?("no_#{time_slots(:two).id}", visible: :all)
  end

  test "voter can return and see their previous responses" do
    poll = polls(:one)
    visit poll_url(poll.token)
    fill_in "Your name", with: "Diana"
    click_on "Join poll"

    choose "yes_#{time_slots(:one).id}"
    click_on "Save my availability"
    assert_text "Availability saved!"

    visit poll_url(poll.token)
    assert_selector "#yes_#{time_slots(:one).id}[checked]"
  end

end
