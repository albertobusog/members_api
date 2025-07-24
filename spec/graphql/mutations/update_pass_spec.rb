require "rails_helper"

RSpec.describe "UpdatePass", type: :request do

  let(:mutation) do
    <<~GQL
      mutation($id: ID!, $name: String!, $visits: Int!, $expiresAt: ISO8601Date!, $price: Float!) {
        updatePass(input: { id: $id, name: $name, visits: $visits, expiresAt: $expiresAt, price: $price }) {
          pass {
            id
            name
            visits
            expiresAt
            price
          }
          errors
        }
      }
    GQL
  end

  context "when admin updates pass" do
    it "updates successfully when no clients have pending visits" do
      admin = create(:user, role: :admin)
      pass = create(:pass,user: admin)

      post "/graphql",
           params: {
             query: mutation,
             variables: {
               id: pass.id,
               name: "Updated",
               visits: 15,
               expiresAt: 2.months.from_now.to_date,
               price: 150.00
             }
           }.to_json,
           headers: auth_headers(admin)

      json = JSON.parse(response.body)
      data = json["data"]["updatePass"]
      expect(data["pass"]["name"]).to eq("Updated")
      expect(data["errors"]).to be_nil
    end

    it "fails if pass does not exist" do
      admin = create(:user, role: :admin)
      post "/graphql",
           params: {
             query: mutation,
             variables: {
               id: -1,
               name: "Not Found",
               visits: 10,
               expiresAt: 1.month.from_now.to_date,
               price: 100.0
             }
           }.to_json,
           headers: auth_headers(admin)

      json = JSON.parse(response.body)
      data = json["data"]["updatePass"]
      expect(data["pass"]).to be_nil
      expect(data["errors"]).to include("Pass not found")
    end

    it "fails when pass has clients with pending visits" do
      admin = create(:user, role: :admin)
      client = create(:user, role: :client)
      pass = create(:pass, user: admin)
      create(:purchase, pass: pass, user: client, remaining_time: 5, purchase_date: Date.today)

      post "/graphql",
        params: {
          query: mutation,
            variables: {
              id: pass.id,
              name: "Should Fail",
              visits: 10,
              expiresAt: 1.month.from_now.to_date,
              price: 100.0
            }
        }.to_json,
      headers: auth_headers(admin)

      json = JSON.parse(response.body)
      data = json["data"]["updatePass"]
      expect(data["pass"]).to be_nil
      expect(data["errors"]).to include("Cannot edit pass with clients having pending visits")
    end

    it "fails when update is invalid (e.g. negative visits)" do
      admin = create(:user, role: :admin)
      pass = create(:pass, user: admin)
    
      post "/graphql",
        params: {
          query: mutation,
            variables: {
              id: pass.id,
              name: "",
              visits: -1,
              expiresAt: 1.month.from_now.to_date,
              price: 100.0
            }
        }.to_json,
      headers: auth_headers(admin)

      json = JSON.parse(response.body)
      data = json["data"]["updatePass"]
      expect(data["pass"]).to be_nil
      expect(data["errors"]).to include(a_string_matching("Visits must be greater than 0")).or include(a_string_matching("Name can't be blank"))
    end

    it "updates only the name" do
    admin = create(:user, role: :admin)
    pass = create(:pass, name: "Old Name", price: 150, visits: 10, expires_at: 1.month.from_now)

    post "/graphql",
      params: {
        query: <<~GQL
          mutation {
            updatePass(input: {
              id: #{pass.id}
              name: "New Name"
            }) {
              pass {
                id
                name
                price
                visits
              }
            errors
            }
          }
        GQL
      }.to_json,
      headers: auth_headers(admin)

      json = JSON.parse(response.body)
      data = json["data"]["updatePass"]["pass"]

      expect(data["name"]).to eq("New Name")
      expect(data["price"]).to eq(pass.price)
      expect(data["visits"]).to eq(pass.visits)
    end

    it "fails when no fields are provided (only id)" do
      admin = create(:user, role: :admin)
      pass = create(:pass, user: admin)
      post "/graphql",
        params: {
          query: <<~GQL
            mutation {
              updatePass(input: { id: #{pass.id} }) {
                pass {
                  id
                  name
                  visits
                  expiresAt
                  price
                }
                errors
              }
            }
          GQL
        }.to_json,
      headers: auth_headers(admin)

      json = JSON.parse(response.body)
      data = json["data"]["updatePass"]

      expect(data["pass"]).to be_nil
      expect(data["errors"]).to include("No fields provided to update")
    end
  end

  context "when client tries to update pass" do
    
    it "returns not authorized" do
      client = create(:user, role: :client)
      pass = create(:pass)
      post "/graphql",
           params: {
             query: mutation,
             variables: {
               id: pass.id,
               name: "Hacked",
               visits: 20,
               expiresAt: 2.months.from_now.to_date,
               price: 999.99
             }
           }.to_json,
           headers: auth_headers(client)

      json = JSON.parse(response.body)
      data = json["data"]["updatePass"]
      expect(data["pass"]).to be_nil
      expect(data["errors"]).to include("Not authorized")
    end
  end
end
