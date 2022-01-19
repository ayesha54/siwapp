class ChangeCommons < ActiveRecord::Migration[5.2]
  def change
    remove_column :commons, :customer_id, :integer
  end
end
