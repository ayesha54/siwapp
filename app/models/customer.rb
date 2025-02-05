class Customer < ActiveRecord::Base
  require "csv"
  include MetaAttributes

  extend ModelCsv

  acts_as_paranoid
  has_many :invoices
  has_many :estimates
  has_many :recurring_invoices
  has_many :customer_items
  has_many :customer_tax
  has_many :payments_customer
  belongs_to :print_template,
    :class_name => 'Template',
    :foreign_key => 'print_template_id',
    optional: true
  belongs_to :email_template,
    :class_name => 'Template',
    :foreign_key => 'email_template_id',
    optional: true
    has_many :custom_items, -> {order(id: :asc)}, autosave: true, dependent: :destroy
    accepts_nested_attributes_for :custom_items,
    :reject_if => :all_blank,
    :allow_destroy => true
  accepts_nested_attributes_for :customer_items,
    :reject_if => :all_blank,
    :allow_destroy => true
  accepts_nested_attributes_for :payments_customer,
    :reject_if => :all_blank,
    :allow_destroy => true

  # Validation
  validate :valid_customer_identification
  # validates_uniqueness_of :name,  scope: :identification
  validates :invoicing_address, format: { without: /<(.*)>.*?|<(.*) \/>/,
    message: "Wrong address format" }
  validates :shipping_address, format: { without: /<(.*)>.*?|<(.*) \/>/,
    message: "Wrong address format" }

  # Behaviors
  acts_as_taggable

  before_destroy :check_invoices

  CSV_FIELDS = [
    "id", "name", "identification", "email", "contact_person",
    "invoicing_address", "shipping_address", "meta_attributes",
    "active"
  ]

  scope :with_terms, ->(terms) {
    return nil if terms.empty?
    where('name ILIKE :terms OR email ILIKE :terms OR identification ILIKE :terms', terms: '%' + terms + '%')
  }

  scope :only_active, ->(boolean = true) {
    return nil unless boolean
    where(active: true)
  }

  def self.to_xls(options = {})

    CSV.generate(options) do |csv|
      column_names
      all.each do |customer|
        csv << customer.attributes.values_at(*column_names)
      end
    end
  end

  def tax_by_name
    hash = {}
    customer_items.each do |item|
      item.customer_item_tax.each do |x|
        tax = Tax.where(id: x.tax_id).first
        key = tax.name
        value = tax.value*item.net_amount/100
        if hash.key? key
          tmp = hash[key]
          hash[key] = tmp + value
        else  
          hash[key] = value
        end
      end
    end
    hash
  end

  def gross_total
    (total_tax + net_amount + service_tax).round(2)
  end

  def green_tax
    t = 0
    customer_items.each do |item|
      nobed = item.quantity_bed == nil ? 1 : item.quantity_bed
      t += item.quantity*nobed*3
    end
    t
  end

  def total_tax
    tax + gov_tax + green_tax
  end

  def get_status
    if due == 0
      :paid
    else
      :pending
    end
  end

  def service_tax
    net_amount*0.1
  end

  def gov_tax
    (net_amount+service_tax+tax)*0.12
  end

  def tax
    t = 0
    customer_items.each do |item|
      ct = CustomerItemTax.where(customer_item_id: item.id)
      tax = Tax.where(id: ct.pluck(:tax_id)).sum :value
      t += item.net_amount*tax/100
    end
    t
  end

  def paid
    payments_customer.where(customer_id: id).sum :amount || 0
  end

  def due
    (gross_total - paid).round(2)
  end

  def to_s
    if name?
      name
    elsif identification?
      identification
    elsif email?
      email
    else
      'Customer'
    end
  end

  def have_items_discount?
    customer_items.each do |item|
      if item.discount && item.discount > 0
        return true
      end
    end
    false
  end

  def net_amount
    total = 0
    customer_items.each do |item|
      total += item.net_amount
    end
    return total
  end

  def gross_amount
    total = 0
    total += net_amount
    Tax.where(id: customer_tax.pluck(:tax_id)).each do |tax|
      total += tax.value
    end
    return total
  end
  
  def to_jbuilder
    Jbuilder.new do |json|
      json.(self, *(attribute_names - ["name_slug", "deleted_at"]))
    end
  end

  # csv format
  def self.csv(results)
    csv_stream(results, self::CSV_FIELDS, results.meta_attributes_keys)
  end

  def send_email
    # There is a deliver_later method which we could use
    CustomerMailer.email_customer(self).deliver_now
  end

  def pdf(html)
    WickedPdf.new.pdf_from_string(html,
      margin: {:top => "20mm", :bottom => 0, :left => 0, :right => 0})
  end

  def get_print_template
    return self.print_template ||
      Template.find_by(template_type: 'customer',name: "Print Customer") ||
      Template.first
  end

  # Returns the invoice template if set, and the default otherwise
  def get_email_template
    return self.email_template ||
    Template.find_by(template_type: 'customer',name: "Email Customer") ||
      Template.first
  end

private

  def check_invoices
    if self.total > self.paid
      errors[:base] << "This customer can't be deleted because it has unpaid invoices"
      throw(:abort)
    end
  end

  def self.ransackable_scopes(auth_object = nil)
    [:with_terms, :only_active]
  end

  def valid_customer_identification
    unless name? or identification?
      errors.add :base, "Name or identification is required."
    end
  end

end
