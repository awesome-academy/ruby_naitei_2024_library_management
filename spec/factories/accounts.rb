FactoryBot.define do
  factory :account do
    email { Faker::Internet.email }
    password { "password" }
    is_admin { false }

    trait :admin do
      is_admin { true }
    end

    trait :with_user do
      after(:create) do |account|
        create(:user, account: account)
      end
    end
  end
end
