FactoryBot.define do
  factory :user do
    citizen_id { Faker::Number.number(digits: 12) }
    name { Faker::Name.name }
    birth { 20.years.ago.to_date }
    gender { 1 }
    phone { "0123456789" }
    address { Faker::Address.full_address }
    association :account
  end
end
