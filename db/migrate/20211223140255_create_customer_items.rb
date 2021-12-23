class CreateCustomerItems < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_items do |t|
      t.references :room, foreign_key: true
      t.references :bed, foreign_key: true
      t.decimal :quantity
      t.decimal :discount
      t.string :description
      t.float :net_amount
      t.integer :tax
      t.decimal :unitary_cost

      t.timestamps
    end
  end
end
