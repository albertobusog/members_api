class Pass < ApplicationRecord
  validates :name, presence: true
  validates :visits, numericality: { greater_than: 0 }
  validates :expires_at, presence: true
end