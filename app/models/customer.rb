class Customer < ActiveRecord::Base
  include MetaAttributes

  extend ModelCsv

  acts_as_paranoid
  has_many :invoices
  has_many :estimates
  has_many :recurring_invoices
  belongs_to :print_template,
    :class_name => 'Template',
    :foreign_key => 'print_template_id',
    optional: true
  belongs_to :email_template,
    :class_name => 'Template',
    :foreign_key => 'email_template_id',
    optional: true

  # Validation
  validate :valid_customer_identification
  validates_uniqueness_of :name,  scope: :identification
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

  def total
    invoices.where(draft: false, failed: false).sum :gross_amount || 0
  end

  def paid
    invoices.where(draft: false, failed: false).sum :paid_amount || 0
  end

  def due
    total - paid
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

  def get_print_template(name)
    return self.print_template || Template.find_by(name: name) || Template.first
  end

  # Returns the invoice template if set, and the default otherwise
  def get_email_template
    return self.email_template ||
      Template.find_by(email_default: true) ||
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
