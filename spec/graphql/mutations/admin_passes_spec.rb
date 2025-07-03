require "rails_helper"

RSpec.describe "AdminPasses", type: :request do
  let(:admin) { create(:user, role: "admin") }
  let(:client1) { create(:user, role: "client") }
  let(:client2) { create(:user, role: "client") }

  let!(:pass1) { create(:pass, name: "Pass1", user: admin) }
  let!(:pass2) { create(:pass, name: "Pass2", user: admin) }

  let(:query) do
    <<-GQL
      query {
        allPasses {
          id
          name
          visits
          expiresAt
          user {
            email
          }
        }
      }
    GQL
  end

  it "returns all passes for admin " do
    post "/graphql",
      params: { query: query }.to_json,
      headers: auth_headers(admin)

    json = JSON.parse(response.body)
    data = json["data"]["allPasses"]

    expect(data.count).to eq(2)
    expect(data.map { |p| p["name"] }).to include("Pass1", "Pass2")
  end
end
