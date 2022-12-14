class Friend < ApplicationRecord
  validates  :id_user1, :id_user2, presence: true


  has_one :users
end