class CreateBattles < ActiveRecord::Migration[7.0]
  def change
    create_table :battles do |t|
      t.integer :id_match
      t.integer :id_user
      t.column(:notation, 'char(8)')

      t.timestamps
    end
  end
end
