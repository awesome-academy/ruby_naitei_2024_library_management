class Account < ApplicationRecord
  enum status: {active: 0, ban: 1}
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable, :trackable, :timeoutable,
         :lockable, omniauth_providers: [:google_oauth2]

  VALID_ATTRIBUTES = %i(email password password_confirmation).freeze
  mail_regex = Regexp.new(Settings.VALID_EMAIL_REGEX)
  validates :email, presence: true,
                    length: {maximum: Settings.email_max_length},
                    format: {with: mail_regex}
  validates :password, presence: true,
                    length: {minimum: Settings.min_password_length},
                    allow_nil: true
  has_one :user, dependent: :destroy

  before_save :downcase_email

  def toggle_status
    active? ? ban! : active!
  end

  def forget
    update_column :remember_id, nil
  end
  class << self
    def ransackable_attributes _auth_object = nil
      %w(email status)
    end

    def from_omniauth access_token
      data = access_token.info
      Account.where(email: data["email"]).first_or_create do |account|
        account.password = Devise.friendly_token[0, 20]
        account.uid = access_token[:uid]
        account.provider = access_token[:provider]
      end
    end
  end
  private

  def downcase_email
    email.downcase!
  end
end
