class AddVisitedAtToVisits < ActiveRecord::Migration[8.0]
  def change
    add_column :visits, :visited_at, :datetime, null: true
  end
end
