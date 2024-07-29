class Author < ApplicationRecord
  has_many :books
  has_many :author_followers

  validates :name, :birth, :bio, :nationality, :profile_url, presence: true
end
