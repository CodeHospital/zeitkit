class User < ActiveRecord::Base
  authenticates_with_sorcery!
  include NilStrings

  attr_accessible :email,
    :password,
    :password_confirmation,
    :name,
    :company_name,
    :zip,
    :street,
    :city,
    :currency

  has_many :clients
  has_many :worklogs
  has_many :invoices
  has_many :notes
  has_many :expenses

  has_one :temp_worklog_save
  has_one :invoice_default

  before_validation :set_initial_currency, on: :create

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email, :currency
  validates_uniqueness_of :email

  after_create :build_invoice_default
  after_create :build_initial_temp_worklog_save

  def set_temp_password(temp_pw)
    self.password = temp_pw
    self.password_confirmation = temp_pw
  end

  def build_initial_temp_worklog_save
    temp_save = TempWorklogSave.new(user_id: self.id)
    temp_save.save
  end

  def string_fields_to_nil
    [:company_name, :zip, :street, :city]
  end

  def build_invoice_default
    id = InvoiceDefault.new(user_id: self.id)
    id.save
  end


  def unpaid_worklogs_by_client
    unpaid = []
    clients.each do |client|
      total = Worklog.unpaid.where(client_id: client.id).sum(:total_cents)
      next if total == 0
      unpaid.push({client: client.name,
        total: Money.new(total, currency)
      })
    end
    unpaid
  end

  def unpaid_by_client
    unpaid = []
    clients.each do |client|
      total = Worklog.unpaid.where(client_id: client.id).sum(:total_cents)
      total += Expense.unpaid.where(client_id: client.id).sum(:total_cents)
      next if total == 0
      unpaid.push({client: client.name,
        total: Money.new(total, currency)
      })
    end
    unpaid
  end

  def currency
    Money::Currency.new read_attribute(:currency)
  end

  def set_initial_currency
    self.currency = Money.default_currency.iso_code.to_s
  end

  def total_all_invoices
    Money.new invoices.sum(:total_cents), currency
  end

end
