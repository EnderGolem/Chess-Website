class CreateHistoryMatches < ActiveRecord::Migration[7.0]
  def change
    create_table :history_matches do |t|
      t.integer :id_user

      t.timestamps
    end
  end
end
