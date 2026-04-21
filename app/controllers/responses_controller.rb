class ResponsesController < ApplicationController
  before_action :load_poll
  before_action :load_participant

  def bulk
    unless @participant
      redirect_to poll_url(@poll.token) and return
    end

    statuses = params[:responses] || {}
    ActiveRecord::Base.transaction do
      statuses.each do |slot_id, status|
        slot = @poll.time_slots.find_by(id: slot_id)
        next unless slot && Response.statuses.key?(status)
        Response.upsert_for(participant: @participant, time_slot: slot, status: status)
      end
    end

    redirect_to poll_url(@poll.token), notice: "Availability saved!"
  end

  private

  def load_poll
    @poll = Poll.find_by(token: params[:poll_token])
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false unless @poll
  end

  def load_participant
    @participant = @poll&.participants&.find_by(cookie_id: current_cookie_id)
  end
end
