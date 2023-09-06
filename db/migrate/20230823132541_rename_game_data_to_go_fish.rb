class RenameGameDataToGoFish < ActiveRecord::Migration[7.0]
  def change
    rename_column :games, :data, :go_fish
  end
end
