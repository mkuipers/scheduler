class PollsController < ApplicationController
  include PollShowContext

  before_action :load_poll, only: [:show, :update]
  before_action :require_creator, only: [:update]

  def new
    @poll = Poll.new
  end

  def create
    @poll = Poll.new(poll_params)
    @poll.creator_cookie_id = current_cookie_id

    if @poll.save
      redirect_to poll_url(@poll.token)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    assign_poll_show_ivars
  end

  def update
    if @poll.update(poll_update_params)
      redirect_to poll_url(@poll.token)
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def load_poll
    @poll = Poll.find_by(token: params[:poll_token])
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false unless @poll
  end

  def require_creator
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false unless @poll.creator?(current_cookie_id)
  end

  def poll_params
    params.expect(poll: [:creator_name, :title])
  end

  def poll_update_params
    params.expect(poll: [:title, :creator_name])
  end
end
