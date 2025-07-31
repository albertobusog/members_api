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

        json = JSON.parse(response.body)
        data = json["data"]["availablePasses"]

        expect(data.count).to eq(2)
        expect(data.map { |p| p["name"] }).to contain_exactly("Gym", "Yoga")
    end

    it "filters passes by name substring" do
      # create(:purchase, user: client, pass: pass1)
      post "/graphql",
        params: {
          query: <<-GQL
            query {
              availablePasses(nameContains: "yo") {
                name
              }
            }
          GQL
        }.to_json,
        headers: auth_headers(client)

      json = JSON.parse(response.body)
      names = json["data"]["availablePasses"].map { |p| p["name"] }

      expect(names).to eq([ "Yoga" ])
    end

    it "filters passes by minimum price" do
      post "/graphql",
        params: {
          query: <<-GQL
            query {
              availablePasses(minPrice: 150) {
                name
                price
              }
            }
          GQL
      }.to_json,
      headers: auth_headers(client)

      json = JSON.parse(response.body)
      prices = json["data"]["availablePasses"].map { |p| p["price"] }

      expect(prices).to all(be >= 150)
      expect(prices).to eq([ 202.0 ])
    end

    it "filters passes by maximum price" do
      post "/graphql",
        params: {
          query: <<-GQL
           query {
              availablePasses(maxPrice: 150) {
                name
                price
              }
            }
          GQL
        }.to_json,
        headers: auth_headers(client)

      json = JSON.parse(response.body)
      prices = json["data"]["availablePasses"].map { |p| p["price"] }

      expect(prices).to all(be <= 150)
      expect(prices).to eq([ 101.0 ])
    end
  end

  it "returns passes ordered by price ascending" do
    post "/graphql",
      params: { query: query }.to_json,
      headers: auth_headers(client)

      json = JSON.parse(response.body)
      data = json["data"]["availablePasses"]

      expect(data.map { |p| p["price"] }).to eq(data.map { |p| p["price"] }.sort)
  end

  it "exclude passes already acquired by the client" do
    create(:purchase, user: client, pass: pass1)
    post "/graphql",
      params: { query: query }.to_json,
      headers: auth_headers(client)

    json = JSON.parse(response.body)
    data = json["data"]["availablePasses"]

    expect(data.count).to eq(1)
    expect(data.first["name"]).to eq("Yoga")
  end
end
