require "test_helper"

class PollsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @poll = polls(:one)
  end

  test "GET /scheduler renders new poll form" do
    get new_poll_url
    assert_response :success
  end

  test "POST /scheduler creates poll and redirects to show" do
    assert_difference "Poll.count" do
      post polls_url, params: { poll: { creator_name: "Alice", title: "Lunch" } }
    end
    poll = Poll.last
    assert_not_nil poll.token
    assert_redirected_to poll_url(poll.token)
  end

  test "POST /scheduler with blank creator_name renders form again" do
    assert_no_difference "Poll.count" do
      post polls_url, params: { poll: { creator_name: "", title: "Lunch" } }
    end
    assert_response :unprocessable_entity
  end

  test "GET /scheduler/:token shows poll" do
    get poll_url(@poll.token)
    assert_response :success
  end

  test "GET /scheduler/:token with calendar_month passes month to slot calendar" do
    get new_poll_url
    post polls_url, params: { poll: { creator_name: "Calendar tester" } }
    poll = Poll.last
    get poll_url(poll.token, calendar_month: "2026-08")
    assert_response :success
    assert_match(/data-slot-calendar-month-value="2026-08"/, response.body)
  end

  test "GET /scheduler/:token with unknown token returns 404" do
    get poll_url("notexist")
    assert_response :not_found
  end

  test "PATCH /scheduler/:token as creator updates poll" do
    get new_poll_url
    post polls_url, params: { poll: { creator_name: "Alice", title: "Original" } }
    created_poll = Poll.last

    patch poll_url(created_poll.token), params: { poll: { title: "Updated title" } }
    assert_redirected_to poll_url(created_poll.token)
    assert_equal "Updated title", created_poll.reload.title
  end

  test "PATCH /scheduler/:token as non-creator returns 404" do
    get new_poll_url
    patch poll_url(@poll.token), params: { poll: { title: "Hacked" } }
    assert_response :not_found
  end
end
