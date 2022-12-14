class CreateFriends < ActiveRecord::Migration[7.0]
  def change
    create_table :friends do |t|
      t.integer :id_user1
      t.integer :id_user2

      t.timestamps
    end
  end
end
