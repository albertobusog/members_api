# frozen_string_literal: true

class GraphqlController < ApplicationController
  # protect_from_forgery with: :null_session
  # skip_before_action :verify_authenticity_token

  # before_action :authenticate_graphql_user, unless: -> { public_operation? }
  # skip_before_action :verify_authenticity_token
  # before_action :authenticate_user!
  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    user = current_user_from_token

    unless public_operation?(query) || user
      render json: { errors: [ { message: "Not Authorized" } ] }, status: :unauthorized, content_type: "application/json"
      return
    end

    context = {
      current_user: user
    }

    result = MembersApiSchema.execute(
      query,
      variables: ensure_hash(variables),
      context: context,
      operation_name: operation_name
    )

    response.content_type = "application/json"
    render json: result
  rescue JSON::ParserError => e
    render json: { errors: [ { message: "invalid JSON #{e.messge}" } ] }, status: 400
  rescue => e
    render json: { errors: [ { message: e.message } ] }, status: 500
  end

  private

  def current_user_from_token
    token = request.headers["Authorization"]&.split(" ")&.last
    return nil if token.blank?

    begin
      payload = Warden::JWTAuth::TokenDecoder.new.call(token)
      User.find(payload["sub"])
    rescue
      nil
    end
  end

  def authenticate_graphql_user
    head :unauthorized unless current_user_from_token
  end

  def public_operation?(query_string = nil)
  query_string ||= begin
    query_string ||= request.request_parameters["query"] || params[:query]
    query_string.to_s.match?(/mutation\s+(SignIn|SignUp)/i)
  end
    # Rails.logger.debug("Query received: #{query_string}")
    # !!query_string.match?(/mutation\s+(SignIn|SignUp)/i)
    # Rails.logger.debug "PARAMS: #{params.to_unsafe_h.inspect}"
    # query_string = params[:query] || params.dig(:params, :query) || ""
    # query_string.match?(/mutation\s+(SignIn|SignUp)/i)
  end

  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      ambiguous_param.present? ? JSON.parse(ambiguous_param) : {}
    when Hash, ActionController::Parameters
      ambiguous_param
    else
      {}
    end
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

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [ { message: e.message, backtrace: e.backtrace } ], data: {} }, status: 500
  end
end
