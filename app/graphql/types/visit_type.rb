module Types
  class VisitType < Types::BaseObject
    field :id, ID, null: false
    field :purchase, Types::PurchaseType, null: false
    field :visited_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
