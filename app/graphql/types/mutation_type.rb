# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :sign_in, mutation: Mutations::SignIn
    field :sign_up, mutation: Mutations::SignUp
    field :create_pass, mutation: Mutations::CreatePass
    field :update_pass, mutation: Mutations::UpdatePass
    field :delete_pass, mutation: Mutations::DeletePass
    field :acquire_pass, mutation: Mutations::AcquirePass

    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World"
    end
  end
end
