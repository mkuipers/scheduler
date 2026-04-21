class TimeSlotsController < ApplicationController
  include PollShowContext

  before_action :load_poll
  before_action :require_creator

  def create
    if params.dig(:time_slot, :time_window).present?
      result = TimeWindowParser.parse(params[:time_slot][:time_window])
      unless result.ok?
        flash.now[:alert] = result.error
        assign_poll_show_ivars
        render "polls/show", status: :unprocessable_entity and return
      end
      starts_at_minute = result.start_minute
      ends_at_minute   = result.end_minute
    else
      starts_at_minute = params.dig(:time_slot, :starts_at_minute)
      ends_at_minute   = params.dig(:time_slot, :ends_at_minute)
    end

    @time_slot = @poll.time_slots.build(
      date:             params.dig(:time_slot, :date),
      starts_at_minute: starts_at_minute,
      ends_at_minute:   ends_at_minute
    )

    if @time_slot.save
      redirect_to poll_url(@poll.token)
    else
      flash.now[:alert] = @time_slot.errors.full_messages.to_sentence
      assign_poll_show_ivars
      render "polls/show", status: :unprocessable_entity
    end
  end

  def destroy
    slot = @poll.time_slots.find(params[:id])
    slot.destroy!
    redirect_to poll_url(@poll.token)
  end

  private

  def load_poll
    @poll = Poll.find_by(token: params[:poll_token])
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false unless @poll
  end

  def require_creator
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false unless @poll&.creator?(current_cookie_id)
  end
end
