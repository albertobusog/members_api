require 'rails_helper'

RSpec.describe Pass, type: :model do
  it "is valid with valid attributes" do
    pass = Pass.new(name: "Yoga Pack", visits: 10, expires_at: 1.month.from_now)
    expect(pass).to be_valid
  end

  it "is invalid without a name" do
    pass = Pass.new(name: nil, visits: 10, expires_at: 1.month.from_now)
    expect(pass).not_to be_valid
    expect(pass.errors[:name]).to include("can't be blank")
  end

  it "is invalid with visits <= 0" do
    pass = Pass.new(name: "Yoga Pack", visits: 0, expires_at: 1.month.from_now)
    expect(pass).not_to be_valid
    expect(pass.errors[:visits]).to include("must be greater than 0")
  end

  it "is invalid without expires_at" do
    pass = Pass.new(name: "Yoga Pack", visits: 5, expires_at: nil)
    expect(pass).not_to be_valid
    expect(pass.errors[:expires_at]).to include("can't be blank")
  end
end
