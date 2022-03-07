class UpdateCustomerItem < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_items, :room_number, :string
    add_column :customer_items, :quantity_bed, :decimal
  end
end
