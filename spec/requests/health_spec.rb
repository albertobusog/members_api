require "rails_helper"

RSpec.describe "Health check", type: :request do
  it "returns the app status as JSON" do
    get "/health"

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["status"]).to eq("ok")
    expect(body["database"]).to eq("ok")
    expect(body["environment"]).to eq("test")
  end

  it "exposes the default rails health endpoint" do
    get "/up"

    expect(response).to have_http_status(:ok)
  end
end
