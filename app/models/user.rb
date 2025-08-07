class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  enum :role, { client: 0, admin: 1 }, default: :client
  has_many :purchases
  has_many :passes, through: :purchases

  def active_purchase 
    purchases
      .where("valid_until >= ?", Date.today)
      .where("remaining_visits > 0")
      .order(:valid_until)
      .first
  end
end
