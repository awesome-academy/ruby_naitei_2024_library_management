class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :rating, presence: true
end
