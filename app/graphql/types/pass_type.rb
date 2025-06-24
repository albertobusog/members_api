module Types
  class PassType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :visits, Integer, null: false
    field :expires_at, GraphQL::Types::ISO8601Date, null: false
  end
end
