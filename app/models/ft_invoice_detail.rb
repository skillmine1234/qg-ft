class FtInvoiceDetail < ApplicationRecord

  attribute :req_timestamp, :datetime
  attribute :rep_timestamp, :datetime

  has_one :audit_log, class_name: 'FundsTransferAuditLog'
  has_many :audit_steps, :class_name => 'FtAuditStep', :as => :ft_auditable
  
  as_enum :status_code, [:FAILED, :RETURNED_FROM_BENEFICIARY, :NEW, :SENT_TO_BENEFICIARY, :SCHEDULED_FOR_NEXT_WORKDAY, :IN_PROCESS, :COMPLETED, :ONHOLD, :'TIMED OUT'], map: :string, source: :status_code

  # searcher needs a scope to limit access to authorized records
  scope :accessible_records, lambda { |customer_ids|
    where("customer_id IN (?) and req_timestamp >= ?", customer_ids, "#{ENV["CONFIG_ILM_MIN_DATE"]}")
  }

  scope :failed_invoices, -> { where("funds_transfer_id is null") }

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