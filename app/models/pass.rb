class Pass < ApplicationRecord
  has_many :purchases, dependent: :restrict_with_error
  belongs_to :user

  validates :name, presence: true
  validates :visits, numericality: { greater_than: 0 }
  validates :expires_at, presence: true

  def active?
    expires_at.present? && expires_at > Date.today
  end
end
