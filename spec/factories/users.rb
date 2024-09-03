FactoryBot.define do
  factory :user do
    citizen_id { Faker::Number.number(digits: 12) }
    name { Faker::Name.name }
    birth { 20.years.ago.to_date }
    gender { 1 }
    phone { Faker::Number.number(digits: 10) }
    address { Faker::Address.full_address }
    association :account
    after(:build) do |user|
      user.profile_image.attach(io: File.open(Rails.root.join("app/assets/images/default_avatar.png")), filename: "default_avatar.png", content_type: "image/png")
    end
  end
end
