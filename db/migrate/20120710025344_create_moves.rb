class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.integer :position
      t.integer :user_id
      t.integer :game_id

      t.timestamps
    end
  end
end
