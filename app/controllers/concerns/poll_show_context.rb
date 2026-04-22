# Sets instance variables expected by polls/show when rendering outside PollsController#show
# (e.g. time slot create failures that re-render the poll page).
module PollShowContext
  extend ActiveSupport::Concern

  private

  def assign_poll_show_ivars
    @presets = PollPresets.new(@poll).call
    @is_creator = @poll.creator?(current_cookie_id)
    @participant = @poll.participants.find_by(cookie_id: current_cookie_id)
    @calendar_month = calendar_month_for_poll_show
  end

  def calendar_month_for_poll_show
    from_param = normalize_calendar_month_param(params[:calendar_month])
    return from_param if from_param

    month_from_date_string(params.dig(:time_slot, :date))
  end

  def normalize_calendar_month_param(raw)
    return nil if raw.blank?
    return nil unless raw.to_s.match?(/\A\d{4}-\d{1,2}\z/)

    y, m = raw.to_s.split("-").map(&:to_i)
    return nil if y < 2000 || y > 2100 || m < 1 || m > 12

    format("%04d-%02d", y, m)
  end

  def month_from_date_string(str)
    return nil if str.blank?

    d = Date.iso8601(str.to_s)
    d.strftime("%Y-%m")
  rescue ArgumentError
    nil
  end
end
