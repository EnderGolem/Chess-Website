class Message < ApplicationRecord
  validates :id_user, :id_match, :msg, presence: true

  has_one :users
end