FactoryBot.define do
  factory :visit do
    purchase
    attended { true }
  end
end
