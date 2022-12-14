class User < ApplicationRecord
  validates :username, :email, presence: true
  validates :email, uniqueness: true

  has_secure_password
  has_many :friends
  has_many :messages
  has_many :history_matches

end