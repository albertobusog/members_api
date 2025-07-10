require "rails_helper"

RSpec.describe "SignIn", type: :request do
  let(:user) { create(:user, email: "newcust@demo.com", password: "password1234") }

  let(:query) do
    <<-GQL
      mutation ($email: String!, $password: String!) {
        signIn(input: {email: $email, password: $password}) {
          user {
            id
            email
            role
          }
          token
          errors
        }
      }
    GQL
  end

  context "when credentials are valid" do
  it "returns token if user its validated" do
    user

     post "/graphql",
     params: {
      query: query,
      variables: {
        email: "newcust@demo.com",
        password: "password1234",
        role: "client"
      }.to_json,
      headers: {
        "Content-Type" => "application/json"
      }
     }.to_json,
    headers: { "Content-Type" => "application/json" }
    # puts "STATUS: #{response.status}"
    # puts "BODY:\n#{response.body}"

    json = JSON.parse(response.body)
    data = json["data"]["signIn"]

    expect(data["user"]["email"]).to eq("newcust@demo.com")
    expect(data["token"]).not_to be_nil
    expect(data["errors"]).to be_empty
    end
  end

  context "when password is incorrect" do
   it "returns nil token and error message" do
      user

      post "/graphql", params: {
        query: query,
        variables: {
          email: "newcust@demo.com",
          password: "wrongpass"
        }
      }.to_json,
      headers: { "Content-Type" => "application/json" }

      json = JSON.parse(response.body)
      data = json["data"]["signIn"]

      expect(data["token"]).to be_nil
      expect(data["user"]).to be_nil
      expect(data["errors"]).to include("Invalid credentials")
    end
  end
end
