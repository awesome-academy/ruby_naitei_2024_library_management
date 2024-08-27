FactoryBot.define do
  factory :borrow_book do
    association :user
    association :book
    association :request
    borrow_date { 2.days.from_now }
    is_borrow { true }
  end
end
