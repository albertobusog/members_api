class CreatePurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :purchases do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pass, null: false, foreign_key: true
      t.integer :remaining_visits

      t.timestamps
    end
  end
end
