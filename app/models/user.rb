class User < ApplicationRecord
  belongs_to :account
  has_many :borrow_books
  has_many :requests
  has_many :favorites
  has_many :ratings
  has_many :comments
  has_many :author_followers

  validates :citizen_id, :name, :birth, :gender, :phone, :address, :profile_url, presence: true
end
