module Mutations
  class DeletePass < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Not authorized" unless user&.admin?

      pass = Pass.find_by(id: id)

      if pass&.destroy
        { success: true, errors: [] }
      else
        { success: false, errors: ["Could not delete pass"] }
      end
    end
  end
end