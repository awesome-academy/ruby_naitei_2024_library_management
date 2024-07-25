class User < ApplicationRecord
  VALID_ATTRIBUTES = %i(citizen_id name birth gender phone address).freeze

  belongs_to :account
  has_many :borrow_books
  has_many :requests
  has_many :favorites
  has_many :ratings
  has_many :comments
  has_many :author_followers

  enum gende: {male: 0, female: 1}
  
  validates :citizen_id, presence: true, length: {is: Settings.digit_12}
  validates :name, presence: true, length: {maximum: Settings.digit_50}
  validates :birth, presence: true
  validates :phone, presence: true
  validates :address, presence: true, length: {maximum: Settings.digit_255}
  scope :for_account, ->(account_id){where(account_id:)}
end
