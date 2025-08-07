class Purchase < ApplicationRecord
  def active?
    valid_until.present? && valid_until >= Date.today && remaining_visits > 0
  end
  belongs_to :user
  belongs_to :pass
  has_many :visits, dependent: :destroy

  validates :remaining_visits, numericality: { greater_than_or_equal_to: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :purchase_date, presence: true
  validates :valid_until, presence: true, comparison: { greater_than_or_equal_to: Date.today, message: "must be a future date" }
end
