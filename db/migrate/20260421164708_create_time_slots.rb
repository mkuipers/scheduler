class CreateTimeSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :time_slots do |t|
      t.references :poll, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :starts_at_minute, null: false
      t.integer :ends_at_minute, null: false

      t.timestamps
    end

    add_index :time_slots, [:poll_id, :date]
    add_index :time_slots, [:poll_id, :starts_at_minute, :ends_at_minute]
    add_index :time_slots, [:poll_id, :date, :starts_at_minute, :ends_at_minute], unique: true, name: "index_time_slots_on_poll_date_window"
  end
end
