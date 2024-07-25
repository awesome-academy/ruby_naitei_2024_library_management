class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :comment_text, presence: true
end
