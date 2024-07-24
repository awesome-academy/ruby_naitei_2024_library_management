class BookInventory < ApplicationRecord
  belongs_to :book

  validates :available_quantity, presence: true
end
