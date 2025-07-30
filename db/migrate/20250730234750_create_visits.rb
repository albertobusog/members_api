class CreateVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :visits do |t|
      t.references :purchase, null: false, foreign_key: true
      t.boolean :attended

      t.timestamps
    end
  end
end
