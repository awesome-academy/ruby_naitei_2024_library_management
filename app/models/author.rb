class Author < ApplicationRecord
  AUTHOR_PARAMS = %i(name birth bio nationality gender profile_image).freeze
  has_many :books, dependent: :destroy
  has_many :author_followers, dependent: :destroy
  has_one_attached :profile_image

  enum gender: {male: 0, female: 1}

  scope :order_by_name, ->{order(name: :asc)}
  validates :name, length: {maximum: Settings.digit_50}
  validates :bio, length: {maximum: Settings.digit_255}
  validates :name, :birth, :bio, :nationality, :profile_image, presence: true

  class << self
    def ransackable_attributes auth_object = nil
      if auth_object&.is_admin
        %w(name birth gender bio nationality profile_url created_at updated_at)
      else
        %w(name)
      end
    end

    def ansackable_associations _auth_object = nil
      %w(books author_followers)
    end
  end
end
