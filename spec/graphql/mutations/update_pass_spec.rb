require "rails_helper"

RSpec.describe "UpdatePass", type: :request do
  let(:admin) { create(:user, role: "admin") }
  let(:client) { create(:user, role: "client") }
  let(:pass) { create(:pass, name: "Original", visits: 10, expires_at: 1.month.from_now) }

  let(:mutation) do
    <<~GQL
      mutation($id: ID!, $name: String!, $visits: Int!, $expiresAt: ISO8601Date!) {
        updatePass(input: { id: $id, name: $name, visits: $visits, expiresAt: $expiresAt }) {
          pass {
            id
            name
            visits
            expiresAt
          }
          errors
        }
      }
    GQL
  end

  context "when admin updates pass" do
    it "updates successfully when no clients have pending visits" do
      post "/graphql",
           params: {
             query: mutation,
             variables: {
               id: pass.id,
               name: "Updated",
               visits: 15,
               expiresAt: 2.months.from_now.to_date
             }
           }.to_json,
           headers: auth_headers(admin)

      json = JSON.parse(response.body)
      data = json["data"]["updatePass"]
      expect(data["pass"]["name"]).to eq("Updated")
      expect(data["errors"]).to be_empty
    end
  end

  context "when client tries to update pass" do
    it "returns not authorized" do
      post "/graphql",
           params: {
             query: mutation,
             variables: {
               id: pass.id,
               name: "Hacked",
               visits: 20,
               expiresAt: 2.months.from_now.to_date
             }
           }.to_json,
           headers: auth_headers(client)

      json = JSON.parse(response.body)
      data = json["data"]["updatePass"]
      expect(data["pass"]).to be_nil
      expect(data["errors"]).to include("Not authorized")
    end
  end
end