# frozen_string_literal: true

module Mutations
  class SingUp < BaseMutation
    argument :email, String, requiered: true
    argument :password, String, requiered: true
    argument :role, String, requiered: true

    field :user, Types:UserType, nell: true
    field :errors, [String], null: true

    def resolve (email:, password:, role: )
      user = User.new(email: email, password: password, role: role)
      if user.save
        { user: user, errors: [] }
      else
        { user: nil, errors: user.errors.full_messages }
      end
    end
  end
end
