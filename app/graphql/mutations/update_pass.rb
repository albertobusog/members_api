module Mutations
  class UpdatePass < BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: true
    argument :visits, Integer, required: true
    argument :expires_at, GraphQL::Types::ISO8601Date, required: true
    argument :price, Float, required: false

    field :pass, Types::PassType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, name:, visits:, expires_at:, price:)
      user = context[:current_user]
      return { pass: nil, errors: [ "Not authorized" ] } unless user&.admin?

      pass = Pass.find_by(id: id)
      return { pass: nil, errors: [ "Pass not found" ] } unless pass

      if pass.purchases.where("remaining_visits > 0").exists?
        return { pass: nil, errors: [ "Cannot edit pass with clients having pending visits" ] }
      end

      if pass.update(name: name, visits: visits, expires_at: expires_at, price: price)
        { pass: pass, errors: [] }
      else
        { pass: nil, errors: pass.errors.full_messages }
      end
    end
  end
end
