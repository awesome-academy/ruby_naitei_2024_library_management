class Category < ApplicationRecord
  has_many :books
  has_many :subcategories, class_name: Category.name, foreign_key: :parent_id
  belongs_to :parent_category, class_name: Category.name, foreign_key: :parent_id, optional: true

  scope :no_parent_category, -> { where(parent_id: nil) }

  validates :name, presence: true
end
