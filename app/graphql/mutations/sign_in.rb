# frozen_string_literal: true

module Mutations
  class SignIn < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :token, String, null: true
    field :user, Types::UserType, null: true
    field :errors, [ String ], null: true

    def resolve (email:, password:)
      user = User.find_for_authentication(email: email)
      unless user&.valid_password?(password)
        return {
          user: nil,
          token: nil,
          errors: [ "Invalid credentials" ]
          }
      end

      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first

      {
        user: user,
        token: token,
        errors: []
      }
    end
  end
end
