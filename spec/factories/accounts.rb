FactoryBot.define do
  factory :account do
    email { Faker::Internet.email }
    password { "password" }

    trait :with_user do
      after(:create) do |account|
        create(:user, account: account)
      end
    end
  end
end
