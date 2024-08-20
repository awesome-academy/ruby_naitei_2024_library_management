FactoryBot.define do
  factory :request do
    association :user
    status { 1 }
  end
end
