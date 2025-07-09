FactoryBot.define do
  factory :purchase do
    association :user
    association :pass
    remaining_visits { 10 }
    remaining_time { 60 }
    purchase_date { Date.today }
    price { 100.11 }
  end
end
