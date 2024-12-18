class CreateUserCarRanks < ActiveRecord::Migration[6.1]
  def change
    create_table :user_car_ranks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :car, null: false, foreign_key: true
      t.float :rank_score, null: false, default: 0.0

      t.timestamps
    end

    add_index :user_car_ranks, [:user_id, :car_id], unique: true
  end
end
