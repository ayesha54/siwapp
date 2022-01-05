class CreateBeds < ActiveRecord::Migration[5.2]
  def change
    create_table :beds do |t|
      t.references :room, foreign_key: true
      t.integer :name

      t.timestamps
    end
  end
end
