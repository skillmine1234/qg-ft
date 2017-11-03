class FtAuditStep < ApplicationRecord

  belongs_to :ft_auditable, :polymorphic => true

  attribute :req_timestamp, :datetime
  attribute :rep_timestamp, :datetime
  
  def readonly?
    true 
  end
    
end