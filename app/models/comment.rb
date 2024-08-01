class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :book

  scope :latest, ->{order(created_at: :desc)}
  scope :oldest, ->{order(created_at: :asc)}

  scope :sorted_by, lambda {|sort_param|
    sort_param == "oldest" ? oldest : latest
  }

  validates :comment_text, presence: true
end
