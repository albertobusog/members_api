require 'rails_helper'

RSpec.describe Visit, type: :model do
  describe "associations" do
    it { should belong_to(:purchase) }
  end

  describe "validations" do
    it { should allow_value([true, false]).for(:attended) }
  end
end