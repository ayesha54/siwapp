class CustomerItem < ActiveRecord::Base
  belongs_to :room
  belongs_to :bed
  belongs_to :customer, optional: true

  def base_amount
    (unitary_cost.to_f * quantity.to_f)
  end
end
