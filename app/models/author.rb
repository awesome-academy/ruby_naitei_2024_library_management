class Author < ApplicationRecord
  AUTHOR_PARAMS = %i(name birth bio nationality gender profile_image).freeze
  has_many :books, dependent: :destroy
  has_many :author_followers, dependent: :destroy
  has_one_attached :profile_image

  enum gender: {male: 0, female: 1}

  scope :order_by_name, ->{order(name: :asc)}

  validates :name, :birth, :bio, :nationality, :profile_image, presence: true
end
