class CustomerItem < ApplicationRecord
  belongs_to :room
  belongs_to :bed
end
