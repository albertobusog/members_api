require "rails_helper"

RSpec.describe "RegisterAttendance", type: :request do
  let(:client) { create(:user, role: :client) }
  let(:pass) { create(:pass, visits: 5, expires_at: 1.month.from_now) }

  let(:mutation) do
    <<-GQL
      mutation {
        registerAttendance(input: {}){
          success
          errors
          purchase {
            remainingVisits
          }
        }
      }
    GQL
  end

  def execute_register_attendance(headers:)
    post "/graphql",
      params: {
        query: mutation
      }.to_json,
      headers: headers
      JSON.parse(response.body)["data"]["registerAttendance"]
  end

  context "when a client register a visit" do
    it "successfully register a visit and reduce remaining visits" do
      purchase = create(:purchase, user: client, pass: pass, remaining_visits: 3, valid_until: 5.days.from_now.to_date)
    data = execute_register_attendance(headers: auth_headers(client))

      expect(data["success"]).to eq(true)
      expect(data["errors"]).to be_nil
      expect(purchase.reload.remaining_visits).to eq(2)
    end

    it "fails when user its not authenticated" do
      data = execute_register_attendance(headers: { "Content-Type" => "application/json" })

      expect(data["success"]).to be false
      expect(data["errors"]). to include ("Not authorized")
    end

    it "fails if purchase has no remaining visits" do
      client.purchases.destroy_all
      create(:purchase, user: client, pass: pass, remaining_visits: 1, valid_until: 5.days.from_now.to_date)
      execute_register_attendance(headers: auth_headers(client))
      data = execute_register_attendance(headers: auth_headers(client))

      expect(data["success"]).to be false
      expect(data["errors"]). to include("No active pass available")
    end

    it "fails if user has no active purchase" do
      data = execute_register_attendance(headers: auth_headers(create(:user, role: :client)))

      expect(data["success"]).to be false
      expect(data["errors"]). to include ("No active pass available")
    end
  end
end
