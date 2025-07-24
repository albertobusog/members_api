module Mutations
  class DeletePass < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: true

    def resolve(id:)
      return { success: false, errors: [ "Not authorized" ] } unless context[:current_user]&.admin?

      pass = Pass.find_by(id: id)
      return { success: false, errors: [ "Pass not found" ] } unless pass
      return { success: false, errors: [ "Cannot delete pass with clients having pending visits" ] } if pass.purchases.where("remaining_visits > 0").exists?

      pass.destroy ? { success: true, errors: nil } : { success: false, errors: [ "Could not delete pass" ] }
    end
  end
end
