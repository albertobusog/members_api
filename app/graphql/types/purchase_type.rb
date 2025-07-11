module Types
  class PurchaseType < Types::BaseObject
    field :id, ID, null: false
    field :remaining_visits, Integer, null: false
    field :remaining_time, Integer, null: false
    field :purchase_date, GraphQL::Types::ISO8601Date, null: false
    field :price, Float, null: false
  end
end
