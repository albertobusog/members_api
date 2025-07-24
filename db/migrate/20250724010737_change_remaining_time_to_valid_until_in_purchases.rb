class ChangeRemainingTimeToValidUntilInPurchases < ActiveRecord::Migration[8.0]
  def change
    remove_column :purchases, :remaining_time, :integer
    add_column :purchases, :valid_until, :date
  end
end
