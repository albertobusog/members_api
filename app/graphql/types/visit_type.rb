module Types
  class VisitType < Types::BaseObject
    field :id, ID, null: false
    field :attended, Boolean, null: false
    field :purchase, Types::PurchaseType, null: false
  end
end
