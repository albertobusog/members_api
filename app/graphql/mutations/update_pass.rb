module Mutations
  class UpdatePass < BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :visits, Integer, required: false
    argument :expires_at, GraphQL::Types::ISO8601Date, required: false
    argument :price, Float, required: false

    field :pass, Types::PassType, null: true
    field :errors, [ String ], null: true

    def resolve(id:, name: nil, visits: nil, expires_at: nil, price: nil)
      return { pass: nil, errors: [ "Not authorized" ] } unless context[:current_user].admin?

      pass = Pass.find_by(id: id)
      return { pass: nil, errors: [ "Pass not found" ] } unless pass
      return { pass: nil, errors: [ "Cannot edit pass with clients having pending visits" ] } if pass.purchases.where("remaining_visits > 0").exists?
      atributes = { 
        name: name,
        visits: visits,
        expires_at: expires_at,
        price: price
      }.compact
      # atributes = {}
      # atributes[:name] = name if name
      # atributes[:visits] = visits if visits
      # atributes[:expires_at] = expires_at if expires_at
      # atributes[:price] = price if price

      return { pass: nil, errors: [ "No fields provided to update" ] } if atributes.empty?

      pass.update(atributes) ?
      { pass: pass, errors: nil } :
      { pass: nil, errors: pass.errors.full_messages }
    end
  end
end
