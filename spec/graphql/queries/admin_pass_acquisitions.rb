require "rails_helper"

RSpec.describe "AdminPassAcquisitions", type: :request do
  let(:admin)  { create(:user, :admin) }
  let(:client) { create(:user, :client) }

  let!(:pass_a) { create(:pass, name: "Yoga 10", visits: 10, price: 200) }
  let!(:pass_b) { create(:pass, name: "Gym 5",  visits: 5,  price: 120) }

  let!(:purchase_a) { create(:purchase, :active, user: client, pass: pass_a, remaining_visits: 7) }
  let!(:purchase_b) { create(:purchase, :active, user: client, pass: pass_b, remaining_visits: 2) }

  let(:query_all) do
    <<~GQL
      query {
        adminPassAcquisitions {
          id
          name
          purchases {
            id
            remainingVisits
            validUntil
            purchaseDate
            user { id email }
          }
        }
      }
    GQL
  end

  let(:query_one) do
    <<~GQL
      query($passId: ID) {
        adminPassAcquisitions(passId: $passId) {
          id
          name
          purchases {
            id
            remainingVisits
            validUntil
            purchaseDate
            user { id email }
          }
        }
      }
    GQL
  end

  context "as admin" do
    it "lists all passes with their purchasers" do
      gql_post(query: query_all, headers: auth_headers(admin))

      expect(response).to have_http_status(:ok)
      expect(gql_errors).to be_nil

      data = gql_data("adminPassAcquisitions")
      yoga = data.find { |p| p["name"] == "Yoga 10" }
      expect(yoga["purchases"].first["user"]["email"]).to eq(client.email)
      expect(yoga["purchases"].first["remainingVisits"]).to eq(7)
    end

    it "filters by passId" do
      gql_post(query: query_one, variables: { passId: pass_b.id }, headers: auth_headers(admin))

      expect(gql_errors).to be_nil
      data = gql_data("adminPassAcquisitions")
      expect(data.size).to eq(1)
      expect(data.first["id"]).to eq(pass_b.id.to_s)
      expect(data.first["purchases"].map { _1["id"] }).to include(purchase_b.id.to_s)
    end

    it "returns empty purchases when a pass has no buyers" do
      lonely = create(:pass, name: "Pilates 3", visits: 3, price: 90)
      gql_post(query: query_one, variables: { passId: lonely.id }, headers: auth_headers(admin))

      expect(gql_errors).to be_nil
      data = gql_data("adminPassAcquisitions")
      expect(data.size).to eq(1)
      expect(data.first["purchases"]).to eq([])
    end
  end

  context "as client" do
    it "is not authorized" do
      gql_post(query: query_all, headers: auth_headers(client))
      expect(gql_errors&.first&.dig("message")).to include("Not authorized")
    end
  end

  context "unauthenticated" do
    it "is not authorized" do
      gql_post(query: query_all, headers: { "Content-Type" => "application/json" })
      expect(gql_errors&.first&.dig("message")).to include("Not authorized")
    end
  end
end
