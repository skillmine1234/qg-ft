require "qg/ft/engine"

module Qg
  module Ft
    NAME = 'Funds Transfer'
    GROUP = 'funds-transfer'
    MENU_ITEMS = [:ft_purpose_code, :funds_transfer_customer, :ft_customer_account, :ft_saf_transfer, :ft_purge_saf_transfer]
    MODELS = ['FundsTransferCustomer','FtUnapprovedRecord', 'FtPurposeCode','FtIncomingRecord','IncomingFile',
             'IncomingFileRecord','FtIncomingFile','FtCustomerAccount','FtApbsIncomingFile','FtApbsIncomingRecord',
             'FtSafTransfer','FtPurgeSafTransfer','NachMember','FtInvoiceDetail','FtCustomerDisableList']
    TEST_MENU_ITEMS = []
    #COMMON_MENU_ITEMS = [:incoming_file]
    REPORTS = []
    #OPERATIONS = [:funds_transfers]

    mattr_accessor :access_all_routes
  end
end