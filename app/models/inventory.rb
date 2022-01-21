class Inventory < ActiveRecord::Base
  belongs_to :category
  def value_id
    "#{price}_#{id}"
  end
end
