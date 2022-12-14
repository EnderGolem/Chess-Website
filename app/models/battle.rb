class Battle < ApplicationRecord
  validates :id_matches, :id_user, :notation, presence: true

  has_one :matches
end