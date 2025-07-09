require 'rails_helper'

RSpec.describe Purchase, type: :model do
   it "is valid with valid attributes" do
    purchase = build(:purchase)
    expect(purchase).to be_valid
  end

  it "is invalid if remaining_visits is negative" do
    purchase = build(:purchase, remaining_visits: -1)
    expect(purchase).to be_invalid
    expect(purchase.errors[:remaining_visits]).to include("must be greater than or equal to 0")
  end

  it "is invalid if price is negative" do
    purchase = build(:purchase, price: -10.00)
    expect(purchase).to be_invalid
    expect(purchase.errors[:price]).to include("must be greater than or equal to 0")
  end

  it "is invalid without a purchase_date" do
    purchase = build(:purchase, purchase_date: nil)
    expect(purchase).to be_invalid
    expect(purchase.errors[:purchase_date]).to include("can't be blank")
  end

  it "is invalid if remaining_time is negative" do
    purchase = build(:purchase, remaining_time: -5)
    expect(purchase).to be_invalid
    expect(purchase.errors[:remaining_time]).to include("must be greater than or equal to 0")
  end


end
