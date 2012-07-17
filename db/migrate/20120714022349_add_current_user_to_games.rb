class AddCurrentUserToGames < ActiveRecord::Migration
  def change
    add_column :games, :current_user, :integer
  end
end
