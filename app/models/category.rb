class Category < ApplicationRecord
  belongs_to :parent
  has_many :books
  has_many :subcategories, class_name: Category.name, foreign_key: :parent_id
  belongs_to :parent_category, class_name: Category.name, optional: true

  validates :name, presence: true
end
