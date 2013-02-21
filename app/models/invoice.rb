class Invoice < ActiveRecord::Base

  include NilStrings
  include TotalHelper

  attr_accessible :client_id,
    :includes_vat,
    :user_id,
    :vat,
    :paid_on,
    :total,
    :note,
    :number,
    :content,
    :payment_terms,
    :payment_info

  belongs_to :user
  belongs_to :client
  has_many :worklogs

  validates :user_id, :client_id, :content, :number, :total, :vat, presence: true
  validates_uniqueness_of :number, scope: :user_id

  def calc_vat_total
    if includes_vat
      total
    else
      (total * 100/vat).round(2)
    end
  end

  def string_fields_to_nil
    [:payment_terms, :payment_info, :note]
  end

  def generate_number
    return 1 if user.invoices.empty?
    # This is ok for the start.
    user.invoices.last.number + 1
  end

  def vat_last_invoice
    return 19.0 if user.invoices.empty?
    user.invoices.last.vat
  end

  def set_initial_values!
    merge_with_invoice_defaults!
    self.vat = vat_last_invoice if !vat
    self.number = generate_number
  end

  def merge_with_invoice_defaults!
    InvoiceDefault.defaults.each do |field|
      self[field.to_s] = user.invoice_default[field.to_s]
    end
  end

end
