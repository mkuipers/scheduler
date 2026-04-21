class CreateResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :responses do |t|
      t.references :participant, null: false, foreign_key: true
      t.references :time_slot, null: false, foreign_key: true
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :responses, [:participant_id, :time_slot_id], unique: true
  end
end
