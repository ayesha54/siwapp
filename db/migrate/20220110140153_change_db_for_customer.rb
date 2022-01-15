class ChangeDbForCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :meal, :string
    add_column :templates, :template_type, :string
  end
end
