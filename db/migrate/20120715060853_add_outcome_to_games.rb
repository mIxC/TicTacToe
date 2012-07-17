class AddOutcomeToGames < ActiveRecord::Migration
  def change
    add_column :games, :outcome, :integer
  end
end
