module Mutations
  class AcquirePass < BaseMutation
    argument :pass_id, ID, required: true

    field :purchase, Types::PurchaseType, null: true
    field :errors, [ String ], null: true

    def resolve(pass_id:)
      return { purchase: nil, errors: [ "Not authorized" ] } unless context[:current_user]&.client?

      pass = Pass.find_by(id: pass_id)
      return { purchase: nil, errors: [ "Pass not found" ] } unless pass
      return { purchase: nil, errors: [ "Pass already acquired" ] } if Purchase.exists?(user: context[:current_user], pass: pass)

      purchase = Purchase.new(
        user: context[:current_user],
        pass: pass,
        remaining_visits: pass.visits,
        remaining_time: 30,
        purchase_date: Date.today,
        price: pass.price
      )

      purchase.save ? { purchase: purchase, errors: nil } : { purchase: nil, errors: purchase.errors.full_messages }
    end
  end
end
