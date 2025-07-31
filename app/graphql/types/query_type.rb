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
    field :availablePasses, [ Types::PassType ], null: false do
      argument :name_contains, String, required: false
      argument :min_price, Float, required: false
      argument :max_price, Float, required: false
    end

    def availablePasses(name_contains: nil, min_price: nil, max_price: nil)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Not authorized " unless user&.role == "client"

      acquired_pass_ids = user.purchases.select(:pass_id)
      passes = Pass.where.not(id: acquired_pass_ids)
      passes = passes.where("LOWER(name) LIKE ?", "%#{name_contains}%") if name_contains.present?
      passes = passes.where("price >= ?", min_price) if min_price.present?
      passes = passes.where("price <= ?", max_price) if max_price.present?

      passes.order(price: :asc)
    end

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

    field :attendance_history, resolver: Queries::AttendanceHistory
  end
end
