module AuthHelpers
  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" }
  end

  def json_body
    JSON.parse(response.body)
  end

  def gql_post(query:, variables: nil, headers: {})
    post "/graphql",
      params: { query: query, variables: variables }.compact.to_json,
      headers: headers
  end

  def gql_data(field)
    json_body.dig("data", field)
  end

  def gql_errors
    json_body["errors"]
  end
end
