FactoryBot.define do
  factory :request do
    association :user
    status { "pending" }
    description { "Mô tả yêu cầu" }
  end
end
