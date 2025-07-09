module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :role, String, null: false

    def role
      object.role.to_s
    end
  end
end
