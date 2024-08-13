class Comment < ApplicationRecord
  VALID_ATTRIBUTES = %i(comment_text book_id parent_id).freeze

  belongs_to :user
  belongs_to :book
  belongs_to :parent_comment, class_name: Comment.name, foreign_key: :parent_id,
    optional: true
  has_many :replies, class_name: Comment.name, foreign_key: :parent_id,
    dependent: :destroy
  scope :latest, ->{order(created_at: :desc)}
  scope :oldest, ->{order(created_at: :asc)}

  scope :sorted_by, lambda {|sort_param|
    sort_param == "oldest" ? oldest : latest
  }
  scope :parent_comments, ->{where(parent_id: nil)}

  validates :comment_text, presence: true
end
