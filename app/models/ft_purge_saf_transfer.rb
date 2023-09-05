class FtPurgeSafTransfer < ActiveRecord::Base
  include Approval
  include FtApproval
  
  STATUS_CODES = [['NEW','NEW'],['FAILED','FAILED']]

  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'

  before_validation :get_reference_no, if: -> {"approval_status=='U'"}
  
  validates_uniqueness_of :reference_no, scope: [:approval_status]
  validates_presence_of :reference_no, :from_req_timestamp, :to_req_timestamp
  validates_length_of :customer_id, maximum: 15, allow_blank: true
  
  after_save :purge_transactions, if: -> {"approval_status=='A' && !Rails.env.test?"}
  
  def self.options_for_op_name
    [['startTransfer','startTransfer'],['transfer','transfer']]
  end
  
  def self.options_for_transfer_type
    [['NEFT','NEFT'],['IMPS','IMPS'],['RTGS','RTGS'],['FT','FT'],['APBS','APBS']]
  end
  
  def get_reference_no
    max_id = FtPurgeSafTransfer.unscoped.maximum(:id)
    max_id.nil? ? "REF1" : "REF#{max_id+1}"
  end
  
  def get_txns_count
    unless Rails.env.test?
      result = plsql.pk_qg_ft_saf.get_pending_txns_count(pi_from_date: self.from_req_timestamp,
                                                         pi_to_date: self.to_req_timestamp,
                                                         pi_status_code: self.status_code,
                                                         pi_customer_id: self.customer_id,
                                                         pi_op_name: self.op_name,
                                                         pi_req_transfer_type: self.req_transfer_type,
                                                         po_fault_code: nil,
                                                         po_fault_reason: nil)
      raise ::Fault::ProcedureFault.new(OpenStruct.new(code: result.last[:po_fault_code], subCode: nil, reasonText: "#{result.last[:po_fault_reason]}")) if result.last[:po_fault_code].present?
      return result.first
    end
  end
  
  private
  
  def purge_transactions
    result = plsql.pk_qg_ft_saf.purge_pending_txns(pi_user_id: self.created_by,
                                                   pi_approver_id: self.created_by,
                                                   pi_from_date: self.from_req_timestamp,
                                                   pi_to_date: self.to_req_timestamp,
                                                   pi_status_code: self.status_code,
                                                   pi_customer_id: self.customer_id,
                                                   pi_op_name: self.op_name,
                                                   pi_req_transfer_type: self.req_transfer_type)
    self.update_column(:row_count, result)
  end
end