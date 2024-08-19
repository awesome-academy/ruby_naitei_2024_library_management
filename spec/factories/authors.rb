FactoryBot.define do
  factory :author do
    name { Faker::Name.name }
    birth { 40.years.ago.to_date }
    gender { "female" }
    bio { Faker::Lorem.paragraph }
    nationality { Faker::Address.country }
    after(:build) do |author|
      author.profile_image.attach(io: File.open(Rails.root.join("app/assets/images/default_avatar.png")), filename: "default_avatar.png", content_type: "image/png")
    end
  end
end
