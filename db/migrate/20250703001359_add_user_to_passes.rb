class AddUserToPasses < ActiveRecord::Migration[8.0]
  def change
    add_reference :passes, :user, null: false, foreign_key: true
  end
end
