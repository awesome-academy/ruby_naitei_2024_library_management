FactoryBot.define do
  factory :borrow_book do
    association :user
    association :book
    association :request
    borrow_date { 1.week.ago.to_date }
    is_borrow { true }
  end
end
