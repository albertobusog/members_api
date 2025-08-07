require "rails_helper"

RSpec.describe "AcquirePass", type: :request do
  let(:client) { create(:user, role: "client") }
  let (:admin) { create(:user, role: "admin") }
  let(:pass) { create(:pass, visits: 10, price: 100.0, expires_at: 1.month.from_now) }

  let(:mutation) do
    <<-GQL
      mutation($passId: ID!) {
        acquirePass(input: { passId: $passId }) {
          purchase {
            id
            remainingVisits
            validUntil
            purchaseDate
          }
          errors
        }
      }
    GQL
  end

  def acquire(pass_id, headers)
    post "/graphql",
       params: { query: mutation, variables: { passId: pass_id } }.to_json,
       headers: headers

    body = JSON.parse(response.body)

    body["data"] && body["data"]["acquirePass"] ?
      body["data"]["acquirePass"] :
      { 
        "purchase" => nil,
        "errors" => Array(body.dig("errors")&.map { |e| e["message"] })
      }
  end

  context "when client acquires a pass"  do
    it "creates a purchase with correct data" do
      data = acquire(pass.id, auth_headers(client))

      expect(data).not_to be_nil
      expect(data["errors"]).to be_nil
      expect(data["purchase"]["remainingVisits"]).to eq(pass.visits)
      expect(Date.parse(data["purchase"]["validUntil"])).to be > Date.today
      expect(data["purchase"]["purchaseDate"]).to eq(Date.today.to_s)
    end

    it "return not authorized if user is not authenticated" do
      data = acquire(pass.id, { "Content-Type" => "application/json"})
      expect(data["purchase"]).to be_nil
      expect(data["errors"]).to include("Not authorized")
    end

    it "returns not authorized if admin tries to acquire a pass" do
      data = acquire(pass.id, auth_headers(admin))
      expect(data["purchase"]).to be_nil
      expect(data["errors"]).to include("Not authorized")
    end

    it "does not allow acquiring a pass if its inactive" do
      expired_pass = create(:pass, visits: 5, expires_at: Date.yesterday)
      data = acquire(expired_pass.id, auth_headers(client))
      expect(data["purchase"]).to be_nil
      expect(data["errors"]).to include("Pass is not active")
    end
  end

  it "return error if pass does not exist" do
    data = acquire(-999, auth_headers(client))   
    expect(data["purchase"]).to be_nil
    expect(data["errors"]).to include("Pass not found")
  end

context "when validating already acquired passes" do
    it "returns error if the client already has an active pass with visits" do 
      create(:purchase,
        user: client,
        pass: pass,
        valid_until: 10.days.from_now,
        remaining_visits: 5
      )

      data = acquire(pass.id, auth_headers(client))
      expect(data["purchase"]).to be_nil
      expect(data["errors"]).to include("Pass already acquired")
    end

    it "allows purchase if previous pass is expired" do 
      Purchase.new(
        user: client,
        pass: pass,
        valid_until: 5.days.ago,
        remaining_visits: 5,
        price: pass.price,
        purchase_date: Date.today
      ).save(validate: false)
      data = acquire(pass.id, auth_headers(client))
      expect(data).not_to be_nil
      expect(data["errors"]).to be_nil
      expect(data["purchase"]).not_to be_nil
    end

    it "allows purchase if previous pass has no remaining visits" do 
      create(:purchase,
        user: client,
        pass: pass,
        valid_until: 10.days.from_now,
        remaining_visits: 0,
        price: pass.price,
        purchase_date: Date.today
      )

      data = acquire(pass.id, auth_headers(client))
      expect(data).not_to be_nil
      expect(data["errors"]).to be_nil
      expect(data["purchase"]).not_to be_nil
    end
  end
end
