class ResponsesController < ApplicationController
  include PollShowContext

  before_action :load_poll
  before_action :load_participant, only: [:bulk]

  def index
    assign_poll_show_ivars
    @time_slots = @poll.time_slots.ordered_by_date.to_a
    @participants = @poll.participants.order(:name).to_a
    @responses_by_pair =
      if @participants.any? && @time_slots.any?
        Response
          .where(participant: @participants, time_slot: @time_slots)
          .index_by { |r| [r.participant_id, r.time_slot_id] }
      else
        {}
      end
  end

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
