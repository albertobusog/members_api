# frozen_string_literal: true

class GraphqlController < ApplicationController
  PUBLIC_FIELDS = %w[signIn signUp].freeze

  def execute
    query = params[:query]
    user = current_user_from_token

    unless public_operation?(query, params[:operationName]) || user
      render json: { errors: [ { message: "Not authorized" } ] }, status: :unauthorized
      return
    end

    result = MembersApiSchema.execute(
      query,
      variables: prepare_variables(params[:variables]),
      context: { current_user: user },
      operation_name: params[:operationName]
    )

    render json: result
  rescue JSON::ParserError => e
    render json: { errors: [ { message: "invalid JSON #{e.message}" } ] }, status: :bad_request
  rescue => e
    Rails.logger.error("[graphql] #{e.class}: #{e.message}")
    render json: { errors: [ { message: e.message } ] }, status: :internal_server_error
  end

  private

  def current_user_from_token
    token = request.headers["Authorization"]&.split(" ")&.last
    return nil if token.blank?

    payload = Warden::JWTAuth::TokenDecoder.new.call(token)
    User.find_by(id: payload["sub"])
  rescue StandardError
    nil
  end

  # A request may skip authentication only when every root field it selects is
  # public (sign in / sign up).
  def public_operation?(query_string, operation_name = nil)
    document = GraphQL.parse(query_string.to_s)
    operations = document.definitions.grep(GraphQL::Language::Nodes::OperationDefinition)
    operations = operations.select { |op| op.name == operation_name } if operation_name.present?
    return false if operations.empty?

    operations.all? do |operation|
      operation.operation_type == "mutation" &&
        operation.selections.all? { |selection| PUBLIC_FIELDS.include?(selection.name) }
    end
  rescue GraphQL::ParseError
    false
  end

  def prepare_variables(variables_param)
    case variables_param
    when String
      variables_param.present? ? JSON.parse(variables_param) : {}
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end
end
