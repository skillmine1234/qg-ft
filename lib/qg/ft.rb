require "qg/ft/engine"

module Qg
  module Ft
    NAME = 'Funds Transfer'
    GROUP = 'funds-transfer'
    MENU_ITEMS = [:ft_purpose_code, :funds_transfer_customer, :ft_customer_account, :ft_saf_transfer, :ft_purge_saf_transfer, :nach_member]
    MODELS = ['FundsTransferCustomer','FtUnapprovedRecord', 'FtPurposeCode','FtIncomingRecord','IncomingFile','IncomingFileRecord','FtIncomingFile','FtCustomerAccount','FtApbsIncomingFile','FtApbsIncomingRecord','FtSafTransfer','FtPurgeSafTransfer','NachMember']
    TEST_MENU_ITEMS = []
    COMMON_MENU_ITEMS = [:incoming_file]
    REPORTS = true
    OPERATIONS = [:funds_transfers]

    mattr_accessor :access_all_routes
  end
end