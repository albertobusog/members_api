require "rails_helper"

RSpec.describe "RegisterAttendance", type: :request do
  let(:client) { create(:user, role: :client ) }
  let(:pass) { create(:pass, visits: 5, expires_at: 1.month.from_now) }
  let(:purchase) do
    create(:purchase,
      user: client,
      pass:pass,
      remaining_visits: 3,
      valid_until: 10.days.from_now.to_date,
      purchase_date: Date.today)
  end

  let(:mutation) do
    <<-GQL
      mutation($purchaseId: !ID) {
        registerAttendance(input: { purchaseId: $purchaseId}) {
          success
          errors
        }
      }
    GQL
  end

  it "allows client with an active pass to register a visit successfully" do
    post "/grraphql",
      params: {
        query: mutation,
        variables: { purchaseId: purchase.id }
      }.to_json,
      headers: auth_headers(client)

      expect(response).to have_http_status((:ok))
      json = JSON.parse(response.body)
      data = json["data"]["registerVisit"]

      expect(data["success"]).to eq(true)
      expect(data["errors"]).to be_nil
      expect(purchase.reload.remaining_visits).to eq(2)
  end
end