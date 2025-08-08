FactoryBot.define do
  factory :visit do
    association :purchase
    visited_at { Time.current }
  end
end
