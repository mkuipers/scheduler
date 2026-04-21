class Poll < ApplicationRecord
  has_many :participants, dependent: :destroy  # destroys responses first (via participant cascade)
  has_many :time_slots, dependent: :destroy    # safe to destroy after responses are gone
  has_many :responses, through: :participants

  validates :creator_name, presence: true
  validates :creator_cookie_id, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :set_token, on: :create
  before_validation :set_expiry, on: :create

  def creator?(cookie_id)
    creator_cookie_id == cookie_id
  end

  private

  def set_token
    loop do
      self.token = SecureRandom.urlsafe_base64(8)
      break unless Poll.exists?(token: token)
    end
  end

  def set_expiry
    self.expires_at ||= 180.days.from_now
  end
end
