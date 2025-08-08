# frozen_string_literal: true

module Queries
  class AdminPassAcquisitions < Queries::BaseQuery
    argument :pass_id, ID, required: false
    type [ Types::PassType ], null: false

    def resolve(pass_id: nil)
      raise GraphQL::ExecutionError, "Not authorized" unless context[:current_user].admin?

      scope = Pass.includes(purchases: :user).order(:id)
      scope = scope.where(pass_id: pass_id) if pass_id.present?
      scope
    end
  end
end
