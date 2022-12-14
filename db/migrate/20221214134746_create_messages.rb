class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.integer :id_user
      t.integer :id_match
      t.string :msg

      t.timestamps
    end
  end
end
