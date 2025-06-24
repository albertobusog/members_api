FactoryBot.define do
  factory :purchase do
    association :user
    association :pass
    remaining_visits { 10 }
  end
end