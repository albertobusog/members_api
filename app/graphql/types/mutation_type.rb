# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :sing_in, mutation: Mutations::SingIn
    field :sing_up, mutation: Mutations::SingUp
    
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World"
    end
  end
end
