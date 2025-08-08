FactoryBot.define do
  factory :purchase do
    association :user, factory: [ :user, :client ]
    association :pass
    remaining_visits { 10 }
    valid_until { 60.days.from_now.to_date }
    purchase_date { Date.today }
    price { 100.11 }

    trait :active do
      remaining_visits { 5 }
      valid_until { 20.days.from_now.to_date }
    end

    trait :expired do
      valid_until { 5.days.ago.to_date }
    end

    trait :no_visits do
      remaining_visits { 0 }
    end
  end
end
