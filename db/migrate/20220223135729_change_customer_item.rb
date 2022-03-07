class ChangeCustomerItem < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_items, :bed_number, :string
  end
end
