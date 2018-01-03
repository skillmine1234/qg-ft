class FtAuditStep < ApplicationRecord

  belongs_to :ft_auditable, :polymorphic => true
  
  as_enum :status_code, [:FAILED, :RETURNED_FROM_BENEFICIARY, :NEW, :SENT_TO_BENEFICIARY, :SCHEDULED_FOR_NEXT_WORKDAY, :IN_PROCESS, :COMPLETED, :'TIMED OUT'], map: :string, source: :status_code

  attribute :req_timestamp, :datetime
  attribute :rep_timestamp, :datetime
  
  def readonly?
    true 
  end
    
end