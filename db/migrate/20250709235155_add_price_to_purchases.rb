class AddPriceToPurchases < ActiveRecord::Migration[8.0]
  def change
    add_column :purchases, :price, :decimal
  end
end
