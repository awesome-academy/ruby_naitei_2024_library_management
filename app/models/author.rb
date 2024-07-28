class Author < ApplicationRecord
  has_many :books, dependent: :destroy
  has_many :author_followers, dependent: :destroy

  validates :name, :birth, :bio, :nationality, :profile_url, presence: true
end
