module Mutations
  class RegisterAttendance < BaseMutation
    argument :purchase_id, ID, required: true

    field :purchase, Types::PurchaseType, null: true
    field :errors, [ String ], null: false

  end
end