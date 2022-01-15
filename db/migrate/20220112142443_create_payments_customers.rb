class CreatePaymentsCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :payments_customers do |t|
      t.integer :customer_id
      t.date :date
      t.decimal :amount
      t.string :notes

      t.timestamps
    end
  end
end
