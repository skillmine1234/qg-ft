class FtUnapprovedRecord < ActiveRecord::Base
  belongs_to :ft_approvable, :polymorphic => true#, :unscoped => true
  FT_TABLES = ['FundsTransferCustomer', 'FtPurposeCode','IncomingFile', "FtCustomerAccount",'FtPurgeSafTransfer','NachMember','FtCustomerDisableList']
end