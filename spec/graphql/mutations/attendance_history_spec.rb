require "rails_helper"

RSpec.describe "AttendanceHistory", type: :request do
  let(:client) { create(:user, role: :client) }
  let(:admin)  { create(:user, role: :admin) }
  let(:other_client) { create(:user, role: :client) }
  let(:pass)   { create(:pass) }
  let(:purchase) { create(:purchase, user: client, pass: pass) }

  before do
    create_list(:visit, 3, purchase: purchase, attended: true)
  end

  let(:mutation) do
    <<~GQL
      mutation($userId: ID) {
        attendanceHistory(input: { userId: $userId }) {
          visits {
            id
            attended
          }
          errors
        }
      }
    GQL
  end

  context "when client is authenticated" do
    it "returns only their own attendance history" do
      post "/graphql",
        params: {
          query: mutation,
          variables: { userId: nil }
        }.to_json,
        headers: auth_headers(client)

      json = JSON.parse(response.body)
      data = json.dig("data", "attendanceHistory", "visits")

      expect(data.count).to eq(3)
    end
  end

  context "when admin is authenticated" do
    it "can fetch history of a specific client" do
      post "/graphql",
        params: {
          query: mutation,
          variables: { userId: client.id }
        }.to_json,
        headers: auth_headers(admin)

      json = JSON.parse(response.body)
      data = json.dig("data", "attendanceHistory", "visits")

      expect(data.count).to eq(3)
    end

    it "fails if no userId is provided" do
      post "/graphql",
        params: {
          query: mutation,
          variables: {}
        }.to_json,
        headers: auth_headers(admin)

      json = JSON.parse(response.body)
      errors = json.dig("data", "attendanceHistory", "errors")

      expect(errors).to include("userId is required for admins")
    end
  end

  context "when unauthenticated" do
    it "returns not authorized error" do
      post "/graphql",
        params: {
          query: mutation,
          variables: { userId: client.id }
        }.to_json,
        headers: { "Content-Type" => "application/json" }

      json = JSON.parse(response.body)
      errors = json.dig("data", "attendanceHistory", "errors")

      expect(errors).to include("Not authorized")
    end
  end

  context "when client tries to fetch another user's data" do
    it "returns not authorized error" do
      post "/graphql",
        params: {
          query: mutation,
          variables: { userId: other_client.id }
        }.to_json,
        headers: auth_headers(client)

      json = JSON.parse(response.body)
      errors = json.dig("data", "attendanceHistory", "errors")

      expect(errors).to include("Not authorized")
    end
  end
end
