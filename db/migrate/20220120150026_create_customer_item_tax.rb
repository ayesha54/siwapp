class CreateCustomerItemTax < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_item_taxes do |t|
      t.integer :customer_item_id
      t.integer :tax_id
      t.timestamps
    end
  end
end
