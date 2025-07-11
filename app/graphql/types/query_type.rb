# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [ Types::NodeType, null: true ], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ ID ], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    field :all_passes, [ Types::PassType ], null: false

    def all_passes
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Not authorized" unless user&.admin?

      Pass.includes(:user).all
    end
    # Add root-level fields here.
    # They will be entry points for queries on your schema.
    field :passes, [ Types::PassType ], null: false,
    description: "Returns a list of all available passes"

    def passes
      Pass.all
    end
    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World!"
    end
  end
end
