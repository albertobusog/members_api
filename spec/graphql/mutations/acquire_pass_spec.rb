require "rails_helper"

RSpec.describe "AcquirePass", type: :request do
  let(:client) { create(:user, role: "client") }
  let(:pass) { create(:pass, visits: 10, price: 100.0, expires_at: 1.month.from_now) }

  let(:mutation) do
    <<-GQL
      mutation($passId; ID!) {
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

    expect(data["errors"]).to be_empty
    expect(data["purchase"]["remainingVisits"]).to eq(pass.visits)
    expect(data["purchase"]["remainingTime"]).to be > 0
    expect(data["purchase"]["purchaseDate"]).to eq(Date.today.to_s)
    end
  end
end