class Category < ApplicationRecord
  has_many :books, dependent: :nullify
  has_many :subcategories, class_name: Category.name,
            foreign_key: :parent_id, dependent: :nullify
  belongs_to :parent_category, class_name: Category.name,
              foreign_key: :parent_id, optional: true

  scope :no_parent_category, ->{where(parent_id: nil)}
  scope :get_books, ->{where(parent_id: nil).limit(Settings.b).includes(:books)}
  validates :name, presence: true
end
