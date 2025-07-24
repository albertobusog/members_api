require "rails_helper"

RSpec.describe "AcquirePass", type: :request do
  let(:client) { create(:user, role: "client") }
  let (:admin) { create(:user, role: "client") }
  let(:pass) { create(:pass, visits: 10, price: 100.0, expires_at: 1.month.from_now) }

  let(:mutation) do
    <<-GQL
      mutation($passId: ID!) {
        acquirePass(input: { passId: $passId }) {
          purchase {
            id
            remainingVisits
            remainingTime
            purchaseDate
          }
          errors
        }
      }
    GQL
  end

  context "when client acquires a pass"  do
    it "creates a purchase with correct data" do
      post "/graphql",
        params: {
          query: mutation,
          variables: { passId: pass.id }
    }.to_json,
    headers: auth_headers(client)
    
    json = JSON.parse(response.body)
    data = json["data"]["acquirePass"]

    expect(data["errors"]).to be_nil
    expect(data["purchase"]["remainingVisits"]).to eq(pass.visits)
    expect(data["purchase"]["remainingTime"]).to be > 0
    expect(data["purchase"]["purchaseDate"]).to eq(Date.today.to_s)
    end

    it "return not authorized if user is not authenticated" do
      post "/graphql",
        params: {
        query: mutation,
        variables: { passId: pass.id }
      }.to_json,
      headers: { "Content-Type" => "application/json" }
      expect(response.media_type).to eq("application/json")
      # puts response.body unless response.media_type == "application/json"
      json = JSON.parse(response.body)
      data = json["data"]["acquirePass"]

      expect(data["purchase"]).to be_nil
      expect(data["errors"]).to include("Not authorized")
    end

    it "returns not authorized if admin tries to acquire a pass" do
      admin = create(:user, role: "admin")
      post "/graphql",
        params: {
          query: mutation,
          variables: { passId: pass.id }
    }.to_json,
    headers: auth_headers(admin)

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    data = json["data"]["acquirePass"]

    expect(data["purchase"]).to be_nil
    expect(data["errors"]).to include("Not authorized")
    end
  end

  it "return error if pass does not exist" do
        post "/graphql",
          params: {
            query: mutation,
            variables: { passId: -999 }
          }.to_json,
          headers: auth_headers(client)

          json = JSON.parse(response.body)
          data = json["data"]["acquirePass"]

          expect(data["purchase"]).to be_nil
          expect(data["errors"]).to include("Pass not found")
  end

  it "does not allow client to acquire the smae pass twice" do
    Purchase.create!(
      user: client,
      pass: pass,
      remaining_visits: pass.visits,
      remaining_time: 30,
      purchase_date: Date.today,
      price: pass.price
    )

    post "/graphql",
      params: {
        query: mutation,
        variables: { passId: pass.id }
      }.to_json,
      headers: auth_headers(client)

      json = JSON.parse(response.body)
      data = json["data"]["acquirePass"]

      expect(data["purchase"]).to be_nil
      expect(data["errors"]).to include("Pass already acquired")
  end
end
