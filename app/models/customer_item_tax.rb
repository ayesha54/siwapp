class CustomerItemTax < ActiveRecord::Base
  belongs_to :customer_item
  belongs_to :tax
end
