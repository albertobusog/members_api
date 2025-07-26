require "rails_helper"

RSpec.describe "RegisterAttendance", type: :request do
  let(:client) { create(:user, role: :client) }
  let(:pass) { create(:pass, visits: 5, expires_at: 1.month.from_now) }
  let(:purchase) { create(:purchase, user: client, pass: pass, remaining_visits: 3) }

  let(:mutation) do
    <<-GQL
      mutation($purchaseId: ID!) {
        registerAttendance(input: { purchaseId: $purchaseId}) {
          success
          errors
        }
      }
    GQL
  end

  context "when a client register a visit" do
    it "successfully register a visit and reduce remaining visits" do
    post "/graphql",
      params: {
        query: mutation,
        variables: { purchaseId: purchase.id }
      }.to_json,
      headers: auth_headers(client)

      json = JSON.parse(response.body)
      data = json["data"]["registerAttendance"]

      expect(data["success"]).to eq(true)
      expect(data["errors"]).to be_nil
      expect(purchase.reload.remaining_visits).to eq(2)
    end

    it "fails when user its not authenticated" do
      post "/graphql",
        params: {
          query: mutation,
          variables: { purchaseId: purchase.id }
      }.to_json,
      headers: { "Content-Type" => "application/json" }

      json = JSON.parse(response.body)
      data = json["data"]["registerAttendance"]

      expect(data["success"]).to be false
      expect(data["errors"]). to include ("Not authorized")
    end

    it "fails if user is not the owner of the purchase" do
      another_client = create(:user, role: :client)

      post "/graphql",
        params: {
          query: mutation,
          variables: { purchaseId: purchase.id }
      }.to_json,
      headers: auth_headers(another_client)

      json = JSON.parse(response.body)
      data = json["data"]["registerAttendance"]

      expect(data["success"]).to be false
      expect(data["errors"]).to include("Not authorized")
    end

    it "fails if purchase has no remaining visits" do
      purchase.update!(remaining_visits: 0)

      post "/graphql",
        params: {
          query: mutation,
          variables: { purchaseId: purchase.id }
      }.to_json,
      headers: auth_headers(client)

      json = JSON.parse(response.body)
      data = json["data"]["registerAttendance"]

      expect(data["success"]).to be false
      expect(data["errors"]). to include("No remaining visits")
    end
  end
end
