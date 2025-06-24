class Purchase < ApplicationRecord
  belongs_to :user
  belongs_to :pass

  validates :remaining_visits, numericality: { greater_than_or_equal_to: 0 }
end
