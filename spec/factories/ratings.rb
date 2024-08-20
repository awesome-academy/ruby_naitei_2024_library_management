FactoryBot.define do
  factory :rating do
    association :user
    association :book
    rating { 4 }
  end
end
