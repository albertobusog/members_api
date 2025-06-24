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
    expect(data["errors"]).to be_empty
  end
end
