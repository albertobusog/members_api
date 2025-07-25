FactoryBot.define do
  factory :pass do
    name { "Sample Pass" }
    visits { 10 }
    expires_at { 1.month.from_now }
    association :user
    price { 100.1 }
  end
end
