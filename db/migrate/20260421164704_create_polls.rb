class CreatePolls < ActiveRecord::Migration[8.0]
  def change
    create_table :polls do |t|
      t.string :token
      t.string :title
      t.string :creator_cookie_id
      t.string :creator_name
      t.datetime :expires_at

      t.timestamps
    end
    add_index :polls, :token, unique: true
    add_index :polls, :expires_at
  end
end
