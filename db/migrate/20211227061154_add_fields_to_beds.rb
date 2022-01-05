class AddFieldsToBeds < ActiveRecord::Migration[5.2]
  def change
    add_column :beds, :price, :decimal
    add_reference :beds, :room, foreign_key: true
  end
end
