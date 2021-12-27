class CustomerItem < ActiveRecord::Base
  belongs_to :room
  belongs_to :bed
  belongs_to :customer, optional: true
end
