class ChangeCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :pay_method_1, :string
    add_column :customers, :pay_method_2, :string
    add_column :customer_items, :extra, :float
  end
end
