class UsageStatsController < ApplicationController
  def index
    @stats = UsageStats.new.aggregate
  end
end
