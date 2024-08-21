class BookSeries < ApplicationRecord
  has_many :books, dependent: :nullify

  scope :order_by_time, ->{order created_at: :desc}

  validates :title, presence: true

  class << self
    def ransackable_attributes auth_object = nil
      if auth_object&.is_admin
        %w(cover_url created_at description id title updated_at)
      else
        %w(title)
      end
    end

    def ransackable_associations _auth_object = nil
      %w(books)
    end
  end
end
