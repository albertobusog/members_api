require "rails_helper"

RSpec.describe "GraphQL endpoint authorization", type: :request do
  let(:json_headers) { { "Content-Type" => "application/json" } }
  let!(:client) { create(:user, role: :client, email: "client@example.com", password: "password123") }

  def post_graphql(query, variables: {}, headers: json_headers, operation_name: nil)
    post "/graphql",
      params: { query: query, variables: variables, operationName: operation_name }.compact.to_json,
      headers: headers
    JSON.parse(response.body)
  end

  describe "public operations" do
    it "allows signIn without a token" do
      body = post_graphql(<<~GQL, variables: { email: client.email, password: "password123" })
        mutation SignIn($email: String!, $password: String!) {
          signIn(input: { email: $email, password: $password }) {
            token
            user { id email role }
            errors
          }
        }
      GQL

      expect(response).to have_http_status(:ok)
      expect(body.dig("data", "signIn", "token")).to be_present
    end

    it "allows signUp without a token" do
      body = post_graphql(<<~GQL, variables: { email: "new@example.com", password: "password123", role: "client" })
        mutation SignUp($email: String!, $password: String!, $role: String!) {
          signUp(input: { email: $email, password: $password, role: $role }) {
            token
            user { id email role }
            errors
          }
        }
      GQL

      expect(response).to have_http_status(:ok)
      expect(body.dig("data", "signUp", "user", "email")).to eq("new@example.com")
    end

    it "still requires a token when a private field is smuggled into a SignIn operation" do
      post_graphql(<<~GQL)
        mutation SignIn {
          passes { id }
        }
      GQL

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "private operations" do
    let(:query) { "query { passes { id } }" }

    it "rejects requests without a token" do
      body = post_graphql(query)

      expect(response).to have_http_status(:unauthorized)
      expect(body["errors"].first["message"]).to eq("Not authorized")
    end

    it "rejects requests with an invalid token" do
      post_graphql(query, headers: json_headers.merge("Authorization" => "Bearer not-a-token"))

      expect(response).to have_http_status(:unauthorized)
    end

    it "accepts requests with a valid token" do
      post_graphql(query, headers: auth_headers(client))

      expect(response).to have_http_status(:ok)
    end
  end

  describe "CORS" do
    it "answers the preflight request for an allowed origin" do
      process :options, "/graphql", headers: {
        "HTTP_ORIGIN" => "http://localhost:5173",
        "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "POST",
        "HTTP_ACCESS_CONTROL_REQUEST_HEADERS" => "authorization,content-type"
      }

      expect(response).to have_http_status(:ok)
      expect(response.headers["Access-Control-Allow-Origin"]).to eq("http://localhost:5173")
      expect(response.headers["Access-Control-Allow-Methods"]).to include("POST")
      expect(response.headers["Access-Control-Allow-Headers"].downcase).to include("authorization")
    end

    it "does not allow unknown origins" do
      process :options, "/graphql", headers: {
        "HTTP_ORIGIN" => "https://evil.example.com",
        "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "POST"
      }

      expect(response.headers["Access-Control-Allow-Origin"]).to be_nil
    end
  end
end
