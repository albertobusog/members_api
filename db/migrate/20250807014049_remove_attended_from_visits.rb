class RemoveAttendedFromVisits < ActiveRecord::Migration[8.0]
  def change
    remove_column :visits, :attended, :boolean
  end
end
