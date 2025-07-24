class Purchase < ApplicationRecord
  def active?
    valid_until.present? && valid_until >= Date.today && remaining_visits > 0
  end
  belongs_to :user
  belongs_to :pass

  validates :remaining_visits, numericality: { greater_than_or_equal_to: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :purchase_date, presence: true
  validates :valid_until, presence: true
  validate :valid_until_cannot_be_in_the_past

  def valid_until_cannot_be_in_the_past
    if valid_until.present? && valid_until < Date.today
      errors.add(:valid_until, "must be a future date")
    end
  end
end
