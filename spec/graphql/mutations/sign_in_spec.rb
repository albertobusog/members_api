require "rails_helper"

RSpec.describe "SignIn", type: :request do 
  let(:user) {create(:user, email: "newcust@demo.com", password: "password1234") }

  let(:query) do 
    <<-GQL
      mutation ($email: String!, $password: String!) {
        signUp(input: {email: $email, password: $password}) {
          user {
            id
            email
          }
          token
          errors
        }
      }
    GQL
  end
  it "returns token if user its validated" do
    user 

     post "/graphql", 
     params: {
      query: query,
      variables: {
        email: "newcust@demo.com",
        password: "password1234",
      }.to_json,
      headers: {
        "Content-Type" => "application/json"
      }
     }.to_json,
    headers: { "Content-Type" => "application/json" }
    puts "STATUS: #{response.status}"
    puts "BODY:\n#{response.body}"

    json = JSON.parse(response.body)
    data = json["data"]["signIn"]

    expect(data["user"]["email"]).to eq("newcust@demo.com")
    expect(data["token"]).not_to be_nil
    expect(data["errors"]).to be_empty
  end
end

