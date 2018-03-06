class AddColumnVirtualPaymentAddressInFundsTransfers < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists? 'funds_transfers'
      add_column :funds_transfers, :virtual_payment_address, :string, :limit => 255, comment: 'the virtual_payment_address for UPI payment' 
    end
  end
end
