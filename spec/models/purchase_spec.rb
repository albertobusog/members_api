require 'rails_helper'

RSpec.describe Purchase, type: :model do
   it "is valid with valid attributes" do
    purchase = build(:purchase)
    expect(purchase).to be_valid
  end
end
