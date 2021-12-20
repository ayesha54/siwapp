class AddNetAmountToItem < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :net_amount, :float, default: 0
  end
end
