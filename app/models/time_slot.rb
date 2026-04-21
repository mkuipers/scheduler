class TimeSlot < ApplicationRecord
  belongs_to :poll
  has_many :responses, dependent: :destroy

  validates :date, presence: true
  validates :starts_at_minute, presence: true, numericality: { in: 0..1440 }
  validates :ends_at_minute, presence: true, numericality: { in: 0..1440 }
  validate :end_must_be_after_start
  validates :date, uniqueness: { scope: [:poll_id, :starts_at_minute, :ends_at_minute] }

  scope :ordered_by_date, -> { order(:date, :starts_at_minute) }

  def display_label
    "#{format_minute(starts_at_minute)} \u2013 #{format_minute(ends_at_minute)}"
  end

  private

  def end_must_be_after_start
    return unless starts_at_minute.present? && ends_at_minute.present?
    errors.add(:ends_at_minute, "must be after start time") if ends_at_minute <= starts_at_minute
  end

  def format_minute(total_minutes)
    h24 = total_minutes / 60
    min = total_minutes % 60
    suffix = h24 < 12 ? "am" : "pm"
    h12 = h24 % 12
    h12 = 12 if h12 == 0
    format("%d:%02d%s", h12, min, suffix)
  end
end
