require "application_system_test_case"

class PollsTest < ApplicationSystemTestCase
  test "creator flow: create poll and add a time slot" do
    visit "/scheduler"
    assert_selector "h1", text: "Schedule a Meeting"

    fill_in "Your name", with: "Alice"
    fill_in "Meeting title (optional)", with: "Team standup"
    click_on "Get started"

    assert_text "Share link"
    set_date_input("date", "2026-07-01")
    fill_in "Time window (e.g. 2pm-4pm)", with: "9am-10am"
    click_on "Add time slot"

    assert_text "9:00am \u2013 10:00am"
    assert_text "July 1, 2026"
  end

  test "creator can remove a time slot" do
    visit "/scheduler"
    fill_in "Your name", with: "Bob"
    click_on "Get started"

    assert_text "Share link"
    set_date_input("date", "2026-08-15")
    fill_in "Time window (e.g. 2pm-4pm)", with: "2pm-4pm"
    click_on "Add time slot"
    assert_text "August 15, 2026"

    click_on "Remove"
    assert_no_text "August 15, 2026"
  end

  test "voter flow: enter name and submit responses" do
    poll = polls(:one)
    visit poll_url(poll.token)

    assert_selector "h2", text: "When are you available?"
    fill_in "Your name", with: "Charlie"
    click_on "Join"

    assert_selector "h2", text: "Mark your availability, Charlie"
    choose "yes_#{time_slots(:one).id}"
    choose "maybe_#{time_slots(:two).id}"
    click_on "Save my availability"

    assert_text "Availability saved!"
  end

  test "voter can return and see their previous responses" do
    poll = polls(:one)
    visit poll_url(poll.token)
    fill_in "Your name", with: "Diana"
    click_on "Join"

    choose "yes_#{time_slots(:one).id}"
    click_on "Save my availability"
    assert_text "Availability saved!"

    visit poll_url(poll.token)
    assert_selector "#yes_#{time_slots(:one).id}[checked]"
  end

  private

  def set_date_input(id, value)
    find("##{id}")  # wait for element
    page.execute_script("document.getElementById('#{id}').value = '#{value}'")
  end
end
