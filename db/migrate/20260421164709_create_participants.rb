class CreateParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :participants do |t|
      t.references :poll, null: false, foreign_key: true
      t.string :name, null: false
      t.string :cookie_id, null: false

      t.timestamps
    end

    add_index :participants, [:poll_id, :cookie_id], unique: true
  end
end
