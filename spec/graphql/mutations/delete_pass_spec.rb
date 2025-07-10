require "rails_helper"

RSpec.describe "DeletePass", type: :request do
  let(:admin) { create(:user, role: "admin") }
  let(:client) { create(:user, role: "client") }
  let!(:pass) { create(:pass, name: "To Delete", user: admin) }
  # let!(:pass) { create(:pass, name: "To Delete", user: client) }

  let(:mutation) do
    <<-GQL
      mutation($id:ID!) {
        deletePass(input: { id: $id}){
          success
          errors
        }
      }
    GQL
  end

  context "when admin deletes a pass " do
    it "delete it successfully" do
      post "/graphql",
        params: {
          query: mutation,
          variables: { id: pass.id }
        }.to_json,
        headers: auth_headers(admin)

      json = JSON.parse(response.body)
      data = json["data"]["deletePass"]

      expect(data["success"]).to eq(true)
      expect(data["errors"]).to be_empty
      expect(Pass.find_by(id: pass.id)).to be_nil
    end

    it "fails if pass has clients with pending visits" do
      create(:purchase, pass: pass, user: client, remaining_visits: 3, purchase_date: Date.today, remaining_time: 10)

      post "/graphql",
         params: {
           query: mutation,
           variables: { id: pass.id }
         }.to_json,
         headers: auth_headers(admin)

      json = JSON.parse(response.body)
      data = json["data"]["deletePass"]

      expect(data["success"]).to be false
      expect(data["errors"]).to include("Cannot delete pass with clients having pending visits")
    end

  it "fails if destroy fails internally" do
    allow_any_instance_of(Pass).to receive(:destroy).and_return(false)

    post "/graphql",
         params: {
           query: mutation,
           variables: { id: pass.id }
         }.to_json,
         headers: auth_headers(admin)

    json = JSON.parse(response.body)
    data = json["data"]["deletePass"]

      expect(data["success"]).to be false
      expect(data["errors"]).to include("Could not delete pass")
    end
  end

  context "when client tries to delete" do
    it "returns not authorized" do
      post "/graphql",
        params: {
          query: mutation,
          variables: { id: pass.id }
        }.to_json,
        headers: auth_headers(client)

      json = JSON.parse(response.body)
      data = json["data"]["deletePass"]

      expect(data["success"]).to be false
      expect(data["errors"]).to include("Not authorized")
    end
  end
end
