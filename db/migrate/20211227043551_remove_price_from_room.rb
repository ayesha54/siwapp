class RemovePriceFromRoom < ActiveRecord::Migration[5.2]
  def change
    remove_column :rooms, :price, :decimal
    remove_reference :rooms, :bed, foreign_key: true
  end
end
