class Match < ApplicationRecord
  validates  :id_match, presence: true

  has_many :history_matches
  has_many :battles
end