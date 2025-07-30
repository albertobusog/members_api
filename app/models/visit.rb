class Visit < ApplicationRecord
  belongs_to :purchase

  validates :attended, inclusion: { in: [true, false] }
end
