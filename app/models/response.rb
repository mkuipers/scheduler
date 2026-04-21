class Response < ApplicationRecord
  belongs_to :participant
  belongs_to :time_slot

  enum :status, { no: 0, maybe: 1, yes: 2 }

  validates :status, presence: true
  validates :time_slot_id, uniqueness: { scope: :participant_id }

  def self.upsert_for(participant:, time_slot:, status:)
    r = find_or_initialize_by(participant: participant, time_slot: time_slot)
    r.status = status
    r.save!
    r
  end
end
