module Mutations
  class DeletePass < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(id:)
      user = context[:current_user]
      return { success: false, errors: [ "Not authorized" ] } unless user&.admin?

      pass = Pass.find_by(id: id)
      return { success: false, errors: [ "Pass not found" ] } unless pass

      pass&.destroy ? { success: true, errors: [] } : { success: false, errors: ["Could not delete pass"] }
    end
  end
end
