class HistoryMatch < ApplicationRecord
  validates  :id_match,:id_user, presence: true

  has_one :users

  has_one :matches
end