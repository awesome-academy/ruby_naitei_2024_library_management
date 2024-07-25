class Account < ApplicationRecord
  enum status: { active: 0, ban: 1 }
  has_one :user

  has_secure_password

  validates :email, :password_digest, :remember_digest, :status, :is_admin, presence: true
  validates :email, uniqueness: true
end
