class AddPriceToPasses < ActiveRecord::Migration[8.0]
  def change
   add_column :passes, :price, :decimal, precision: 8, scale: 2
  end
end
