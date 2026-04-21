class PurgeExpiredPollsJob < ApplicationJob
  queue_as :default

  def perform
    Poll.where("expires_at < ?", Time.current).find_each(&:destroy!)
  end
end
