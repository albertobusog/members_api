require "rails_helper"

RSpec.describe "AvailablePasses", type: :request do
  let(:client) { create(:user, role: "client") }

  let!(:pass1) { create(:pass, name: "Gym", price: 101.0) }
  let!(:pass2) { create(:pass, name: "Yoga", price: 202.0) }

  let(:query) do
    <<-GQL
      query {
        availablePasses {
          id
          name
          price
        }
      }
    GQL
  end

  context "when authenticated as client" do
    it "returns the list of available passes" do
      post "/graphql",
        params: { query: query }.to_json,
        headers: auth_headers(client)
        # puts "RESPONSE BODY: #{response.body}"
        json = JSON.parse(response.body)
        data = json["data"]["availablePasses"]

        expect(data.count).to eq(2)
        expect(data.map { |p| p["name"] }).to contain_exactly("Gym", "Yoga")
    end
  end

  it "returns passes ordered by price ascending" do
    post "/graphql",
      params: { query: query }.to_json,
      headers: auth_headers(client)
      # puts "RESPONSE BODY: #{response.body}"
      json = JSON.parse(response.body)
      data = json["data"]["availablePasses"]

      expect(data.map { |p| p["price"] }).to eq(data.map { |p| p["price"] }.sort)
  end
end
