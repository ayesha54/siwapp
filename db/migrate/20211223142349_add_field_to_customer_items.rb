class AddFieldToCustomerItems < ActiveRecord::Migration[5.2]
  def change
    add_reference :customer_items, :customer, foreign_key: true
  end
end
