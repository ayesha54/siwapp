class Category < ActiveRecord::Base
  has_many :inventory
  validates :name, presence: true, uniqueness: {case_sensitive: false}
end
