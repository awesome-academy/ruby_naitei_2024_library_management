class Category < ApplicationRecord
  has_many :books, dependent: :destroy
  has_many :subcategories, class_name: Category.name,
            foreign_key: :parent_id, dependent: :destroy
  belongs_to :parent_category, class_name: Category.name,
              foreign_key: :parent_id, optional: true

  scope :no_parent_category, ->{where(parent_id: nil)}

  validates :name, presence: true
end
