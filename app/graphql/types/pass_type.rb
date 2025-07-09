module Types
  class PassType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :visits, Integer, null: false
    field :expires_at, GraphQL::Types::ISO8601Date, null: false
    field :user, Types::UserType, null: false
    field :price, Float, null: false
  end
end
