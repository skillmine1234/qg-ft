module FtApproval  
  extend ActiveSupport::Concern
  included do
    has_one :ft_unapproved_record, :as => :ft_approvable

    after_create :on_create_create_ft_unapproved_record
    after_destroy :on_destory_remove_ft_unapproved_records
    after_update :on_update_remove_ft_unapproved_records
  end

  def on_create_create_ft_unapproved_record
    if approval_status == 'U'
      FtUnapprovedRecord.create!(:ft_approvable => self)
    end
  end

  def on_destory_remove_ft_unapproved_records
    if approval_status == 'U'
      ft_unapproved_record.delete
    end
  end
  
  def on_update_remove_ft_unapproved_records
    if approval_status == 'A' and approval_status_was == 'U'
      ft_unapproved_record.delete
    end
  end 
  
end