class ChangeRoleStringToIntegerInUsers < ActiveRecord::Migration[8.0]
    def up
      User.where(role: "client").update_all(role: 0)
      User.where(role: "admin").update_all(role: 1)
    end

    def down
      User.where(role: 0).update_all(role: "client")
      User.where(role: 1).update_all(role: "admin")
    end
end
