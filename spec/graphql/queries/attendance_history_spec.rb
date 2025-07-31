require "rails_helper"

RSpec.describe "AttendanceHistory", type: :request do
  let(:client) { create(:user, role: :client) }
  let(:admin) { create(:user, role: :admin) }
  let(:other_client) { create(:user, role: :client) }
  let(:pass) { create(:pass, visits: 10) }
  let(:purchase) { create(:purchase, user: client, pass: pass, remaining_visits: 5) }

  before do
    create_list(:visit, 3, purchase: purchase, attended: true)
  end

  let(:query) do
    <<~GQL
      query($userId: ID) {
        attendanceHistory(userId: $userId) {
          id
          attended
          purchase {
            id
          }
        }
      }
    GQL
  end

  def make_request(user: nil, user_id: nil)
    post "/graphql",
      params: {
        query: query,
        variables: user_id ? { userId: user_id } : {}
      }.to_json,
      headers: user ? auth_headers(user) : { "Content-Type" => "application/json" }

    json = JSON.parse(response.body)
    [ json["data"]&.dig("attendanceHistory"), json["errors"] ]
  end

  context "when client is authenticated" do
    it "returns only their own attendance history" do
      data, errors = make_request(user: client)

      expect(errors).to be_nil
      expect(data.count).to eq(3)
      expect(data.all? { |v| v["purchase"]["id"].to_i == purchase.id }).to be true
    end
  end

  context "when admin is authenticated" do
    it "can fetch history of a specific client" do
      data, errors = make_request(user: admin, user_id: client.id)

      expect(errors).to be_nil
      expect(data.count).to eq(3)
    end

    it "fails if no userId is provided" do
      data, errors = make_request(user: admin)

      expect(data).to be_nil
      expect(errors.first["message"]).to include("userId is required for admins")
    end
  end

  context "when unauthenticated" do
    it "returns not authorized error" do
      data, errors = make_request

      expect(data).to be_nil
      expect(errors.first["message"]).to include("Not authorized")
    end
  end

  context "when client tries to fetch another user's data" do
    it "returns not authorized error" do
      data, errors = make_request(user: client, user_id: other_client.id)

      expect(data).to be_nil
      expect(errors.first["message"]).to include("Not authorized")
    end
  end

  context "returns an empty attendance history when" do
    it "client is authenticated but has no purchases" do
      client = create(:user, role: :client)

      data, errors = make_request(user: client)

      expect(errors).to be_nil
      expect(data).to eq([])
    end

    it "admin queries a client with no purchases" do
      admin = create(:user, role: :admin)
      client = create(:user, role: :client)

      data, errors = make_request(user: admin, user_id: client.id)

      expect(errors).to be_nil
      expect(data).to eq([])
    end
  end
end
