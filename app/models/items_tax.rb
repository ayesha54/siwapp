class ItemsTax < ActiveRecord::Base
    belongs_to :item
    belongs_to :tax
end
