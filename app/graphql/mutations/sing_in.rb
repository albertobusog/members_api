# frozen_string_literal: true

module Mutations
  class SingIn < BaseMutation
    argument :email, String, requiered: true
    argument :password, String, requiered: true

    field :token, String, null: true
    field :user, Types:UserType, nell: true
    field :errors, [String], null: true

    def resolve (email:, password:)
      user = User.find_for_authentication(email: email)
      return { user: nill, token: nill, errors: ["Invalid credentials"] } unless user&.valid_password?(password)

      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first

      { user:user, token: token, errrors: [] }
    end
  end
end
