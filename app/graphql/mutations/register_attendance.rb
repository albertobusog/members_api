module Mutations
  class RegisterAttendance < BaseMutation

    field :purchase, Types::PurchaseType, null: true
    field :success, Boolean, null: false
    field :errors, [ String ], null: true

    def resolve
      user = context[:current_user]
      return { success: false, errors: [ "Not authorized" ] } unless user&.client?

      purchase = user.active_purchase
      return { success: false, errors: [ "No active pass available" ] } unless purchase
      return { success: false, errors: [ "No remaining visits" ] } if purchase.remaining_visits <= 0


      purchase.update(remaining_visits: purchase.remaining_visits - 1) ?
        { success: true, purchase: purchase, errors: nil } :
        { success: false, purchase: nil, errors: purchase.errors.full_messages }
    end
  end
end
