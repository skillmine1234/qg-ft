class FundsTransferCustomer < ActiveRecord::Base
  include Approval
  include FtApproval
  include ServiceNotification

  self.table_name = "ft_customers"

  RELATIONS = %w(GUR JOF JOO SOW TRU AUS)
  
  BENE_BACKENDS = %w(NETB UCXP)

  attr_accessor :use_std_relns

  serialize :allowed_relns, ArrayAsCsv

  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'

  has_many :ft_customer_accounts, :primary_key => 'customer_id', :foreign_key => 'customer_id', :class_name => 'FtCustomerAccount'
  
  validates_presence_of :low_balance_alert_at, :identity_user_id, :name, :app_id, :allow_all_accounts, :is_filetoapi_allowed
  validates :low_balance_alert_at, :numericality => { :greater_than => 0}
  validates :identity_user_id, format: {with: /\A[a-z|A-Z|0-9]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9]}'}, :allow_blank => true
  validates :app_id, format: {with: /\A[a-z|A-Z|0-9]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9]}'}
  validates :name, format: {with: /\A[a-z|A-Z|0-9|\s|\.|\-]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9|\s|\.|\-]}'}
  validates :customer_id, :numericality => {:only_integer => true, :message => 'Invalid format, expected format is : {[0-9]}', :allow_blank => true}
  validates_uniqueness_of :app_id, :scope => [:customer_id,:approval_status]
  validate :validate_customer_id
  
  validates :app_id, length: { minimum: 5, maximum: 20 }
  validates :customer_id, length: { maximum: 10 }, :allow_blank =>true
  validates :name, length: {maximum: 100 }
  validates :identity_user_id, length: { maximum: 20 }
  validates :notify_app_code, length: { maximum: 20}, :allow_blank =>true

  validates :apbs_user_no, format: {with: /\A[a-z|A-Z|0-9]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9]}' }, length: {minimum: 7, maximum: 7}, :allow_blank => true
  validate :should_allow_neft?, if: "customer_id.present? && allow_neft=='Y'"
  validate :should_allow_imps?, if: "customer_id.present? && allow_imps=='Y' && allow_all_accounts=='Y'"
  validate :check_needs_purpose_code, if: "allow_apbs == 'Y'"

  validate :presence_of_iam_cust_user
  validate :apbs_values

  validates_presence_of :notify_app_code, :message => "is mandatory if Notify On Status Change? is Y", :if => 'notify_on_status_change?'

  validate :allowed_relns_values
  
  validate :value_of_backend_code

  def notify_on_status_change?
    notify_on_status_change == 'Y' ? true : false
  end

  before_save :to_upcase  

  alias_attribute :is_enabled, :enabled

  def template_variables
    user = IamCustUser.find_by(username: identity_user_id)
    { username: user.try(:username), first_name: user.try(:first_name), last_name: user.try(:last_name), mobile_no: user.try(:mobile_no), 
      email: user.try(:email), service_name: 'FundsTransfer', customer_id: customer_id, app_id: app_id, account_no: ft_customer_accounts.first.try(:account_no) }
  end

  def to_upcase
    unless self.frozen?
      self.name = self.name.upcase unless self.name.nil?
    end
  end

  def validate_customer_id
    errors.add(:customer_id,"is mandatory for corporate") if is_retail == 'N' and customer_id.to_s.empty?
  end

  def presence_of_iam_cust_user
    errors.add(:identity_user_id, 'IAM Customer User does not exist for this username') unless IamCustUser.iam_cust_user_exists?
  end
  
  def apbs_values
    errors.add(:apbs_user_no, 'is mandatory if Allow APBS is Y') if allow_apbs == 'Y' and apbs_user_no.blank?
    errors.add(:apbs_user_name, 'is mandatory if Allow APBS is Y') if allow_apbs == 'Y' and apbs_user_name.blank?
  end
  
  def check_needs_purpose_code
    errors.add(:needs_purpose_code, "should be enabled when APBS is allowed") if needs_purpose_code == 'N'
  end

  def allowed_relns_values
    errors.add(:allowed_relns, "atleast one value should be selected when 'Use Standard Relationships?' is not checked") if allowed_relns.empty? && use_std_relns == 'N'
  end

  def should_allow_neft?
    return true
    # fcr_customer = Fcr::Customer.find_by_cod_cust_id(self.customer_id)
    # if fcr_customer.nil?
    #   errors.add(:customer_id, "no record found in FCR for #{self.customer_id}")
    # else
    #   errors.add(:allow_neft, "NEFT is not allowed for #{self.customer_id} as the data setup in FCR is invalid") unless fcr_customer.transfer_type_allowed?('NEFT')
    # end
  end
  
  def should_allow_imps?
    return true
    # fcr_customer = Fcr::Customer.find_by_cod_cust_id(self.customer_id)
    #
    # if fcr_customer.present?
    #   debit_accounts = fcr_customer.accounts
    #
    #   if debit_accounts.present?
    #     res = Atom::Customer.imps_allowed_for_accounts?(debit_accounts, fcr_customer.ref_phone_mobile)
    #     errors[:base] << res[:reason] unless res == true
    #   else
    #     errors[:base] << "no accounts found in FCR for #{self.customer_id}"
    #   end
    # else
    #   errors.add(:customer_id, "no record found in FCR for #{self.customer_id}")
    # end
  end

  def use_std_relns_value
    allowed_relns.empty? ? 'Y' : 'N'
  end
  
  def value_of_backend_code
    errors.add(:bene_backend, "should be NETB when customer is retail") if is_retail == 'Y' && bene_backend != 'NETB'
  end
end
