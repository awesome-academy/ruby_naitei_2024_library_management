FactoryBot.define do
  factory :cart do
    association :user
    association :book
  end
end
