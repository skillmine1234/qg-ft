class FtCustomerAccount < ActiveRecord::Base
  include Approval
  include FtApproval

  self.table_name = "ft_cust_accounts"
  
  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'

  belongs_to :funds_transfer_customer, :foreign_key => 'customer_id', :primary_key => 'customer_id'
  
  validates_presence_of :customer_id, :account_no, :is_enabled
  validates :customer_id, :account_no, :numericality => {:only_integer => true, :message => 'Invalid format, expected format is : {[0-9]}'}
  validates_uniqueness_of :customer_id, :scope => [:account_no,:approval_status]
  
  validates :customer_id, length: { maximum: 10 }
  validates :account_no, length: { minimum: 5, maximum: 15 }

  validate :validate_customer_id
  validate :validate_account, if: "funds_transfer_customer.present? && funds_transfer_customer.allow_imps=='Y' && funds_transfer_customer.allow_all_accounts=='N'"

  def validate_customer_id
    return true
    # customers = FundsTransferCustomer.where("customer_id =? and enabled =?", customer_id, 'Y')
    # errors.add(:customer_id,"not valid") if customers.empty?
  end
  
  def validate_account
    return true
    # fcr_customer = Fcr::Customer.find_by_cod_cust_id(self.customer_id)
    # atom_customer_by_debit_acct = Atom::Customer.find_by_accountno(self.account_no)
    #
    # if fcr_customer.present? && atom_customer_by_debit_acct.present?
    #   errors.add(:account_no, "Required setup for IMPS transfer not found in ATOM for #{self.account_no}") unless atom_customer_by_debit_acct.imps_allowed?(fcr_customer.ref_phone_mobile)
    # else
    #   errors.add(:customer_id, "no record found in FCR for #{self.customer_id}") if fcr_customer.nil?
    #   errors.add(:account_no, "no record found in ATOM for #{self.account_no}") if atom_customer_by_debit_acct.nil?
    # end
  end
end
