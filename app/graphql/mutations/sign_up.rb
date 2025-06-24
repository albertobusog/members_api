# frozen_string_literal: true

module Mutations
  class SignUp < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true
    argument :role, String, required: true

    field :user, Types::UserType, null: true
    field :errors, [ String ], null: true
    field :token, String, null: true

    def resolve (email:, password:, role:)
      user = User.new(email: email, password: password, role: role)
      if user.save
        token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
        {
          user: user,
          token: token,
          errors: []
        }
      else
        {
          user: nil,
          token: nil,
          errors: user.errors.full_messages
        }
      end
    end
  end
end
