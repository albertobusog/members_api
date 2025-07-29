module Mutations
  class RegisterAttendance < BaseMutation
    argument :purchase_id, ID, required: true

    field :purchase, Types::PurchaseType, null: true
    field :success, Boolean, null: false
    field :errors, [ String ], null: true

    def resolve(purchase_id:)
      return { success: false, errors: [ "Not authorized" ] } unless context[:current_user]&.client?

      purchase = Purchase.find_by(id: purchase_id)
      return { success: false, errors: [ "Purchase not found" ] } unless purchase
      return { success: false, errors: [ "Not authorized" ] } unless purchase.user == context[:current_user]
      return { success: false, errors: [ "No remaining visits" ] } if purchase.remaining_visits <= 0


      purchase.update(remaining_visits: purchase.remaining_visits - 1) ?
        { purchase: purchase, success: true, errors: nil } :
        { success: false, errors: purchase.errors.full_messages }
    end
  end
end
