class AddRequiredColumnsToFtSafTransfers < ActiveRecord::Migration
  def change
    remove_index :ft_saf_transfers, name: 'ft_saf_transfers_01'
    if Rails.configuration.database_configuration[Rails.env]["adapter"] == 'oracle_enhanced'
      execute 'drop index ft_saf_transfers_02'
    end
    add_column :ft_saf_transfers, :app_id, :string, :limit => 50, :comment => 'the app_id asssigned to a customer'
    change_column :ft_saf_transfers, :app_id, :string, null: false
    add_column :ft_saf_transfers, :fault_code, :string, :limit => 50, :comment => 'the code that identifies the business failure reason/exception'
    add_column :ft_saf_transfers, :fault_subcode, :string, :limit => 50, :comment => "the error code that the third party will return"
    add_column :ft_saf_transfers, :fault_reason, :string, :limit => 1000, :comment => 'the english reason of the business failure reason/exception'
    add_column :ft_saf_transfers, :fault_bitstream, :text, :comment => 'the complete exception list/stack trace of an exception that occured in the ESB'
    add_column :ft_saf_transfers, :fault_timestamp, :datetime, :comment => "the SYSDATE when the failure was logged"
    add_column :ft_saf_transfers, :status_code, :string, :limit => 25, :comment => "the status of the transaction"
    change_column :ft_saf_transfers, :status_code, :string, null: false
    change_column :ft_saf_transfers, :customer_id, :string, :null => false
    add_index :ft_saf_transfers, [:customer_id, :req_no], :unique => true, :name => "ft_saf_transfers_01"
    if Rails.configuration.database_configuration[Rails.env]["adapter"] == 'oracle_enhanced'
      execute 'create index ft_saf_transfers_02 on ft_saf_transfers (trunc(req_timestamp), req_transfer_type, customer_id)'
    end
  end
end