class AddPlayerCountToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :player_count, :integer, default: 2
  end
end
