class CreateRoundResults < ActiveRecord::Migration[7.0]
  def change
    create_table :round_results do |t|
      t.text :content
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
