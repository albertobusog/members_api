module Mutations
  class DeletePass < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(id:)
      user = context[:current_user]
      return { success: false, errors: ["Not authorized"] } unless user&.admin?

      pass = Pass.find_by(id: id)
      return { success: false, errors: ["Pass not found"] } unless pass

      if pass.purchases.where("remaining_visits > 0").exists?
        return { success: false, errors: ["Cannot delete pass with clients having pending visits"] }
      end

      pass.destroy ? { success: true, errors: [] } : { success: false, errors: ["Could not delete pass"] }
    end
  end
end
