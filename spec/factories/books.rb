FactoryBot.define do
  factory :book do
    title { "Sample Book Title" }
    summary { "This is a summary of the book." }
    quantity { 10 }
    publication_date { 1.year.ago.to_date }
    association :category
    association :author
    after(:build) do |book|
      book.cover_image.attach(io: File.open(Rails.root.join("app/assets/images/default_cover_image.png")), filename: "default_avatar.png", content_type: "image/png")
    end
  end
end
