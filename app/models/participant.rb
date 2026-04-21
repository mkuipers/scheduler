class Participant < ApplicationRecord
  belongs_to :poll
  has_many :responses, dependent: :destroy

  validates :name, presence: true
  validates :cookie_id, presence: true
  validates :cookie_id, uniqueness: { scope: :poll_id }
end
