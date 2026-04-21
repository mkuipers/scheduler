class PollPresets
  def initialize(poll)
    @poll = poll
  end

  def call
    @poll.time_slots
         .group(:starts_at_minute, :ends_at_minute)
         .order(Arel.sql("MIN(created_at)"))
         .pluck(:starts_at_minute, :ends_at_minute)
  end
end
