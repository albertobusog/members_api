module Mutations
  class AcquirePass < BaseMutation 
    argument :pass_id, ID, required: true

    field :purchase, Types::PurchaseType, null: true
    field :errors, [String], null: false

    def resolve(pass_id:)
      user = context[:current_user]
      return { purchase: nil, errors: ["Not authorized"] } unless user&.client?

      pass = Pass.find_by(id: pass_id)
      return { purchase: nil, errors: ["Passnot found"] } unless pass
      
      purchase = Purchase.new(
        user: user,
        pass: pass,
        remaining_visits: pass.visits,
        remaining_time: 30,
        purchase_date: Date.today,
        price: pass.price
      )

      purchase.save ? { purchase: purchase, errors: [] } : { purchase: nil, errors: purchase.errors.full_messages }
    end

  end
end