class Tax < ActiveRecord::Base
  acts_as_paranoid
  has_many :customer_item_tax
  has_many :items_taxes
  before_destroy :check_is_not_used

  validates :name, presence: true
  validates :value, presence: true, numericality: true

  private

  def check_is_not_used
    if items.count > 0
      errors.add(:base, "Can't delete a tax which is used in some invoices")
      throw(:abort)
    end
  end

  public

  def to_s
    name
  end

  def value_id
    "#{id}_#{value}_#{name}"
  end

  def self.default
    self.where(active: true, default: true)
  end

  def self.enabled
    self.where(active: true)
  end

  def to_jbuilder
    Jbuilder.new do |json|
      json.(self, *(attribute_names - ["deleted_at"]))
    end
  end

end
