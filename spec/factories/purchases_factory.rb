FactoryBot.define do
  factory :purchase do
    association :user
    association :pass
    remaining_visits { 10 }
    valid_until { 60.days.from_now.to_date }
    purchase_date { Date.today }
    price { 100.11 }
  end
end
