class AddStartedAtToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :started_at, :datetime
  end
end
