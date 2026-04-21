# Sets instance variables expected by polls/show when rendering outside PollsController#show
# (e.g. time slot create failures that re-render the poll page).
module PollShowContext
  extend ActiveSupport::Concern

  private

  def assign_poll_show_ivars
    @presets = PollPresets.new(@poll).call
    @is_creator = @poll.creator?(current_cookie_id)
    @participant = @poll.participants.find_by(cookie_id: current_cookie_id)
  end
end
