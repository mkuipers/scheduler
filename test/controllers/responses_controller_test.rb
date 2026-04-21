require "test_helper"

class ResponsesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @poll = polls(:one)
    get new_poll_url
    post poll_participants_url(@poll.token), params: { participant: { name: "Voter" } }
    @participant = Participant.last
  end

  test "bulk POST creates responses for all slots" do
    slot1 = time_slots(:one)
    slot2 = time_slots(:two)

    assert_difference "Response.count", 2 do
      post poll_bulk_responses_url(@poll.token), params: {
        responses: { slot1.id.to_s => "yes", slot2.id.to_s => "maybe" }
      }
    end
    assert_redirected_to poll_url(@poll.token)
    assert @participant.responses.find_by(time_slot: slot1).yes?
    assert @participant.responses.find_by(time_slot: slot2).maybe?
  end

  test "bulk POST updates existing responses" do
    slot = time_slots(:one)
    Response.create!(participant: @participant, time_slot: slot, status: :no)

    assert_no_difference "Response.count" do
      post poll_bulk_responses_url(@poll.token), params: {
        responses: { slot.id.to_s => "yes" }
      }
    end
    assert @participant.responses.find_by(time_slot: slot).yes?
  end

  test "bulk POST without first joining as participant redirects to poll" do
    get new_poll_url  # new cookie, no participant
    post poll_bulk_responses_url(@poll.token), params: {
      responses: { time_slots(:one).id.to_s => "yes" }
    }
    assert_redirected_to poll_url(@poll.token)
  end
end
