class CreateItemsTaxes < ActiveRecord::Migration[5.2]
  def change
    drop_table :items_taxes
    create_table :items_taxes do |t|
      t.integer :tax_id
      t.integer :item_id
      t.timestamps
    end
  end
end
