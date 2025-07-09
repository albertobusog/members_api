class AddPurchaseDateAndRemainingTimeToPurchases < ActiveRecord::Migration[8.0]
  def change
    add_column :purchases, :purchase_date, :datetime
    add_column :purchases, :remaining_time, :integer
  end
end
