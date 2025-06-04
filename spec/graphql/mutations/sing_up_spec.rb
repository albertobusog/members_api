require "rails_helper"

RSpec.describe "SingUp" , type: :request do
  let(:query) do 
    <<-GQL
      mutations ($email: String!, $password: String!, $role: String!) {
        singUp(input: {email: $email, password: $password, role: $role}) {
          user {
            id
            email
            role
          }
          errors
        }
      }
    GQL
  end

  it "singup new customer" do
    post "/graphql", params: {
      query: query,
      variables: {
        email: "newcust@demo.com",
        password: "password1234",
        role: "client"
      }
    }
    json = JSON.parse(response.body)
    data = json["data"]["singUp"]

    expect(data["user"]["email"]).to eq("newcust@demo.com")
    expect(data["user"]["role"]).to eq("client")
    expect(data["errors"]).to be_empty
  end
end