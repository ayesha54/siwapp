class CustomerTax < ActiveRecord::Base
    belongs_to :customer
    belongs_to :tax
end
