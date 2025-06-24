module Mutations
  class CreatePass < BaseMutation
    argument :name, String, required: true
    argument :visits, Integer, required: true
    argument :expires_at, GraphQL::Types::ISO8601Date, required: true

    field :pass, Types::PassType, null: true
    field :errors, [ String ], null: true

    def resolve(name:, visits:, expires_at:)
      user = context[:current_user]
      unless user&.role == "admin"
        return { pass: nil, errors: [ "Not authorized" ] }
      end

      pass = Pass.new(name: name, visits: visits, expires_at: expires_at)

      if pass.save
        { pass: pass, errors: [] }
      else
        { pass: nil, errors: pass.errors.full_messages }
      end
    end
  end
end
