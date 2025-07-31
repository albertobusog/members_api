# frozen_string_literal: true

module Queries
  class AttendanceHistory < Queries::BaseQuery
    argument :user_id, ID, required: false

    type [ Types::VisitType ], null: false

    def resolve(user_id: nil)
      user = context[:current_user]
      return raise GraphQL::ExecutionError, "Not authorized" unless user

      return raise GraphQL::ExecutionError, "userId is required for admins" if user.admin? && user_id.nil?
      return raise GraphQL::ExecutionError, "Not authorized" if user.client? && user_id && user.id.to_s != user_id.to_s

      target_user = user.admin? ? User.find_by(id: user_id) : user
      return raise GraphQL::ExecutionError, "User not found" unless target_user

      Visit.joins(:purchase)
           .where(purchases: { user_id: target_user.id }, attended: true)
    end
  end
end
