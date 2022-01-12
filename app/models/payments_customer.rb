class PaymentsCustomer < ActiveRecord::Base
    belongs_to :customer, optional: true
end
