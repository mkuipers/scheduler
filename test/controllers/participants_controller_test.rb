require "test_helper"

class ParticipantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @poll = polls(:one)
  end

  test "POST creates participant with current cookie and redirects to poll" do
    assert_difference "Participant.count" do
      post poll_participants_url(@poll.token), params: { participant: { name: "Eve" } }
    end
    p = Participant.last
    assert_equal "Eve", p.name
    assert_not_nil p.cookie_id
    assert_redirected_to poll_url(@poll.token)
  end

  test "POST with same cookie find-or-creates (idempotent name update)" do
    get new_poll_url  # set cookie
    post poll_participants_url(@poll.token), params: { participant: { name: "First name" } }
    count_before = @poll.participants.count
    post poll_participants_url(@poll.token), params: { participant: { name: "Updated name" } }
    assert_equal count_before, @poll.participants.reload.count
    assert_equal "Updated name", @poll.participants.order(:updated_at).last.name
  end

  test "POST with blank name returns 422" do
    assert_no_difference "Participant.count" do
      post poll_participants_url(@poll.token), params: { participant: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "PATCH updates participant name" do
    get new_poll_url
    post poll_participants_url(@poll.token), params: { participant: { name: "Original" } }
    participant = Participant.last
    patch poll_participant_url(@poll.token, participant), params: { participant: { name: "Renamed" } }
    assert_equal "Renamed", participant.reload.name
    assert_redirected_to poll_url(@poll.token)
  end

end
