class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :name
      t.integer :user1_id
      t.integer :user2_id

      t.timestamps
    end
  end
end
