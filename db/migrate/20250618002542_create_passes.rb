class CreatePasses < ActiveRecord::Migration[8.0]
  def change
    create_table :passes do |t|
      t.string :name
      t.integer :visits
      t.date :expires_at

      t.timestamps
    end
  end
end
