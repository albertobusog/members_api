require "rails_helper"

RSpec.describe "SignUp", type: :request do
  let(:query) do
    <<-GQL
      mutation($input: SignUpInput!) {
        signUp(input: $input) {
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

  it "signup new customer" do
    post "/graphql",
         params: {
           query: query,
           variables: {
             input: {
               email: "newcust@demo.com",
               password: "password1234",
               role: "client"
             }
           }
         }.to_json,
         headers: { "Content-Type" => "application/json" }

    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    data = json["data"]["signUp"]

    expect(data["user"]["email"]).to eq("newcust@demo.com")
    expect(data["user"]["role"]).to eq("client")
    expect(data["errors"]).to be_nil
  end

  it "SignUp with wrong email format " do
    post "/graphql",
      params: {
        query: query,
        variables: {
          input: {
            email: "newcust",
            password: "password1234",
            role: "admin"
          }
        }
      }.to_json,
      headers: { "Content-Type" => "application/json" }

    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    data = json["data"]["signUp"]

    expect(data["user"]).to be_nil
    expect(data["token"]).to be_nil
    expect(data["errors"]).to include("Email is invalid")
  end

  it "SignUp with a role diferent as client or admin " do
    post "/graphql",
      params: {
        query: query,
        variables: {
          input: {
            email: "newcust@demo.com",
            password: "password1234",
            role: "abmin"
          }
        }
      }.to_json,
      headers: { "Content-Type" => "application/json" }
      puts response.body
    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    # data = json["data"]["signUp"]

    expect(json["data"]).to be_nil
    expect(json["errors"]).not_to be_nil
    expect(data["errors"].first["message"]).to include("abmin is not a valid role")
  end
end
