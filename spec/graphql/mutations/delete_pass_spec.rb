require "rails_helper"

RSpec.describe "DeletePass", type: :request do
  let(:admin) { create(:user, role: "admin") }
  let(:client) { create(:user, role: "client") }
  let!(:pass) { create(:pass, name: "To Delete") }

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
      error = json["errors"].first

      expect(error["message"]).to eq("Not authorized")
    end
  end
end
