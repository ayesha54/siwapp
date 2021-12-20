class RemoveInventoryCategoryFromCommon < ActiveRecord::Migration[5.2]
  def change
    remove_column :commons, :inventory_id
    remove_column :commons, :category_id
  end
end
