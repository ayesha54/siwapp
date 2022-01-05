class AddFieldToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :check_in, :date
    add_column :customers, :check_out, :date
    add_column :customers, :print_template_id, :integer
    add_column :customers, :email_template_id, :integer
  end
end
