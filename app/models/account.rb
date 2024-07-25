class Account < ApplicationRecord
  enum status: {active: 0, ban: 1}
  attr_accessor :remember_id

  VALID_ATTRIBUTES = %i(email password password_confirmation).freeze
  mail_regex = Regexp.new(Settings.VALID_EMAIL_REGEX)
  validates :email, presence: true,
                    length: {maximum: Settings.email_max_length},
                    format: {with: mail_regex}
  validates :password, presence: true,
                    length: {minimum: Settings.min_password_length},
                    allow_nil: true

  has_secure_password

  has_one :user, dependent: :destroy

  before_save :downcase_email
  private

  def downcase_email
    email.downcase!
  end
end