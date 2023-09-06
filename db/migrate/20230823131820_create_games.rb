class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.jsonb :data
      t.datetime :finished_at

      t.timestamps
    end
  end
end
