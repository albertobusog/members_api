require "rails_helper"

RSpec.describe "CreatePass", type: :request do
  let(:admin) { create(:user, email: "admin@demo.com", password: "admin123", role: "admin") }

  let(:query) do
    <<-GQL
      mutation($name: String!, $visits: Int!, $expiresAt: ISO8601Date!) {
        createPass(input: {
          name: $name,
          visits: $visits,
          expiresAt: $expiresAt
        }) {
          pass {
            id
            name
            visits
            expiresAt
          }
          errors
        }
      }
    GQL
  end

  it "creates a pass successfully" do
    token = Warden::JWTAuth::UserEncoder.new.call(admin, :user, nil).first

    post "/graphql",
         params: {
           query: query,
           variables: {
             name: "Yoga Pack",
             visits: 10,
             expiresAt: 1.month.from_now.to_date.iso8601
           }
         }.to_json,
         headers: {
           "Content-Type" => "application/json",
           "Authorization" => "Bearer #{token}"
         }

    json = JSON.parse(response.body)
    data = json["data"]["createPass"]

    expect(data["pass"]["name"]).to eq("Yoga Pack")
    expect(data["pass"]["visits"]).to eq(10)
    expect(data["errors"]).to eq([])
  end

  it "returns error if non-admin tries to create pass" do
    client = create(:user, email: "client@demo.com", password: "client123", role: "client")
    token = Warden::JWTAuth::UserEncoder.new.call(client, :user, nil).first

    post "/graphql",
         params: {
           query: query,
           variables: {
             name: "Pilates Pack",
             visits: 5,
             expiresAt: 1.month.from_now.to_date.iso8601
           }
         }.to_json,
         headers: {
           "Content-Type" => "application/json",
           "Authorization" => "Bearer #{token}"
         }

    json = JSON.parse(response.body)
    data = json["data"]["createPass"]

    expect(data["pass"]).to be_nil
    expect(data["errors"]).to include("Not authorized")
  end
end
