module Mutations
  class AcquirePass < BaseMutation
    argument :pass_id, ID, required: true

    field :purchase, Types::PurchaseType, null: true
    field :errors, [ String ], null: true
    
    def resolve(pass_id:)
      return { purchase: nil, errors: [ "Not authorized" ] } unless context[:current_user]&.client?

      pass = Pass.find_by(id: pass_id)
      return { purchase: nil, errors: [ "Pass not found" ] } unless pass
      return { purchase: nil, errors: [ "Pass is not active" ] } unless pass.active?
      
      Purchase.where(user: context[:current_user], pass: pass)
              .where("valid_until >= ?", Date.today)
              .where("remaining_visits > 0")
              .exists? ?
        { purchase: nil, errors: ["Pass already acquired"] } :
        create_purchase(user = context[:current_user], pass)
    end
    private
    
    def create_purchase(user = context[:current_user], pass)
      purchase = Purchase.new(
        user: context[:current_user],
        pass: pass,
        remaining_visits: pass.visits,
        valid_until: 30.days.from_now.to_date,
        purchase_date: Date.today,
        price: pass.price
      )
      purchase.save ? { purchase: purchase, errors: nil } : { purchase: nil, errors: purchase.errors.full_messages }
    end
  end
end
