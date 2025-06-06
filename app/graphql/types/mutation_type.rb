# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :sign_in, mutation: Mutations::SignIn
    field :sign_up, mutation: Mutations::SignUp
    
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World"
    end
  end
end
