require "rails_helper"

RSpec.describe "Invalid SignIn", type: :request do 
  let(:user) {create(:user, email: "newcust@demo.com", password: "password1234") }

  let(:query) do 
    <<-GQL
      mutation ($email: String!, $password: String!) {
        signIn(input: {email: $email, password: $password}) {
          token
          user {
            id
          }
          errors
        }
      }
    GQL
  end

  it "fails with incorrect password" do
    user 

    post "/graphql", params: {
      query:  query,
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