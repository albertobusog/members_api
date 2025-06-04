require "rails_helper"

RSepec.describe "SingIn", type: :request do 
  let(:user) {create(:user, email: "newcust@demo.com", password: "password1234") }

  let(:query) do 
    <<-GQL
      mutation ($email: String!, $password: String!) {
        singUp(input: {email: $email, password: $password}) {
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

     post "/graphql", params: {
      query: query,
      variables: {
        email: "newcust@demo.com",
        password: "password1234",
      }
    }
    json = JSON.parse(response.body)
    data = json["data"]["singIn"]

    expect(data["user"]["email"]).to eq("newcust@demo.com")
    expect(data["token"]).not_to be_nil
    expect(data["errors"]).to be_empty
  end

end