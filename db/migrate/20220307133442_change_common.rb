class ChangeCommon < ActiveRecord::Migration[5.2]
  def change
    add_column :commons, :pay_method_1, :string
    add_column :commons, :pay_method_2, :string
    add_column :commons, :pcr_test, :string
    add_column :items, :extra, :float
  end
end
