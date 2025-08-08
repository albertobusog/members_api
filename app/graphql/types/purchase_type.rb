module Types
  class PurchaseType < Types::BaseObject
    field :id, ID, null: false
    field :remaining_visits, Integer, null: false
    field :valid_until, GraphQL::Types::ISO8601Date, null: false
    field :purchase_date, GraphQL::Types::ISO8601Date, null: false
    field :price, Float, null: false
    field :user, Types::UserType, null: false
    field :pass, Types::PassType, null: false
  end
end
