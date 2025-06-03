FactoryBot.dfine do
  factory :user do
    email { Facker::Internet.email }
    password { "password123" }
    role { "client" }

    trait :admin do 
      role { "admin" }
    end
  end
end