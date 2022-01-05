class AddPriceToBeds < ActiveRecord::Migration[5.2]
  def change
    add_column :beds, :price, :decimal
  end
end
