class User < ApplicationRecord
  VALID_ATTRIBUTES = %i(citizen_id name birth gender phone address).freeze

  belongs_to :account
  has_many :borrow_books, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :author_followers, dependent: :destroy

  enum gender: {male: 0, female: 1}

  validates :citizen_id, presence: true, length: {is: Settings.digit_12}
  validates :name, presence: true, length: {maximum: Settings.digit_50}
  validates :birth, presence: true
  validates :phone, presence: true
  validates :address, presence: true, length: {maximum: Settings.digit_255}
  scope :for_account, ->(account_id){where(account_id:)}
  scope :order_by_name, ->{order(:name)}
end
