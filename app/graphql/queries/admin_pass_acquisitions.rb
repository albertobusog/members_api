# frozen_string_literal: true

module Queries
  class AdminPassAcquisitions < Queries::BaseQuery
    argument :pass_id, ID, required: false
    type [ Types::PassType ], null: false

    def resolve(pass_id: nil)
      (!context[:current_user] || !context[:current_user].admin?) ? (raise GraphQL::ExecutionError, "Not authorized") : nil
      scope = Pass.includes(purchases: :user).order(:id)
      pass_id.present? ? scope.where(id: pass_id) : scope
    end
  end
end
