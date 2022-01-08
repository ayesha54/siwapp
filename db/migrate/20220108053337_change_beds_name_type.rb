class ChangeBedsNameType < ActiveRecord::Migration[5.2]
  def change
    remove_column :beds, :name, :integer
    add_column :beds, :name, :string
  end
end
