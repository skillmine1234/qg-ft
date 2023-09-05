class FundsTransfer < ApplicationRecord
  
  alias_attribute :fault_subcode, :sub_code


  attribute :req_timestamp, :datetime
  attribute :rep_timestamp, :datetime

  has_one :audit_log, class_name: 'FundsTransferAuditLog'
  has_many :audit_steps, :class_name => 'FtAuditStep', :as => :ft_auditable
  has_one :ft_invoice_detail

  as_enum :status_code, [:FAILED, :RETURNED_FROM_BENEFICIARY, :NEW, :SENT_TO_BENEFICIARY, :SCHEDULED_FOR_NEXT_WORKDAY, :IN_PROCESS, :COMPLETED, :ONHOLD, :Pending, :SettlementInProcess, :SettlementCompleted, :SettlementReversed, :CreditConfirmationReceived], map: :string, source: :status_code
  as_enum :req_transfer_type, [:ANY, :NEFT, :IMPS, :RTGS, :FT, :APBS], map: :string, source: :req_transfer_type
  as_enum :transfer_type, [:NEFT, :IMPS, :RTGS, :FT, :APBS], map: :string, source: :transfer_type

  # searcher needs a scope to limit access to authorized records
  scope :accessible_records, lambda { |customer_ids|
    where("customer_id IN (?) and req_timestamp >= ?", customer_ids, "#{ENV["CONFIG_ILM_MIN_DATE"]}")
  }

  def readonly?
    true 
  end
    
  def req_bitstream
    audit_log.request_bitstream
  end

  def rep_bitstream
    audit_log.reply_bitstream
  end

end