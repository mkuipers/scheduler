# Aggregates public usage metrics for the stats dashboard.
class UsageStats
  CHART_DAYS = 14

  Result = Data.define(
    :total_polls,
    :avg_polls_per_day,
    :total_responses,
    :avg_participants_per_day,
    :polls_by_day,
    :responses_by_day
  )

  def aggregate
    Result.new(
      total_polls: Poll.count,
      avg_polls_per_day: safe_avg(Poll.count, day_span(Poll.minimum(:created_at))),
      total_responses: Response.count,
      avg_participants_per_day: safe_avg(Participant.count, day_span(Participant.minimum(:created_at))),
      polls_by_day: series_for(Poll, :created_at),
      responses_by_day: series_for(Response, :updated_at)
    )
  end

  private

  def day_span(first_time)
    return nil if first_time.blank?

    first_date = first_time.in_time_zone.to_date
    [(Date.current - first_date).to_i + 1, 1].max
  end

  def safe_avg(count, days)
    return 0.0 if days.nil? || days.zero?

    (count.to_f / days).round(2)
  end

  def series_for(model, column)
    end_date = Date.current
    start_date = end_date - (CHART_DAYS - 1)
    range_start = start_date.beginning_of_day
    range_end = end_date.end_of_day

    col = model.connection.quote_column_name(column)
    raw = model
      .where(model.arel_table[column].gteq(range_start))
      .where(model.arel_table[column].lteq(range_end))
      .group(Arel.sql("date(#{col})"))
      .count

    (start_date..end_date).map do |d|
      key = d.strftime("%Y-%m-%d")
      { date: d, count: raw[key] || raw[d] || 0 }
    end
  end
end
