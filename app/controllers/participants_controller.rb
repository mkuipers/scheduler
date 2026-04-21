class ParticipantsController < ApplicationController
  include PollShowContext

  before_action :load_poll

  def create
    @participant = @poll.participants.find_or_initialize_by(cookie_id: current_cookie_id)
    @participant.name = params.dig(:participant, :name).to_s.strip

    if @participant.save
      redirect_to poll_url(@poll.token)
    else
      assign_poll_show_ivars
      render "polls/show", status: :unprocessable_entity
    end
  end

  def update
    @participant = @poll.participants.find(params[:id])
    if @participant.cookie_id == current_cookie_id && @participant.update(name: params.dig(:participant, :name))
      redirect_to poll_url(@poll.token)
    else
      assign_poll_show_ivars
      render "polls/show", status: :unprocessable_entity
    end
  end

  private

  def load_poll
    @poll = Poll.find_by(token: params[:poll_token])
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false unless @poll
  end
end
