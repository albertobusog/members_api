# frozen_string_literal: true

module Types
  module Inputs
    class SignUpInput < Types::BaseInputObject
      graphql_name "SignUpInput"

      argument :email, String, required: true
      argument :password, String, required: true
      argument :role, String, required: true
    end
  end
end