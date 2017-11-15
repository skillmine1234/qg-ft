class AddAppidToFtSafTransfers < ActiveRecord::Migration
  def change
    if Rails.configuration.database_configuration[Rails.env]["adapter"] == 'oracle_enhanced'
      execute 'drop index uk_ft_saf_transfers_01'
      execute 'drop index uk_ft_saf_transfers_02'
    end     
    add_column :ft_saf_transfers, :app_id, :string, :limit => 50, :null => false, :comment => 'the app_id asssigned to a customer'
    change_column :ft_saf_transfers, :customer_id, :string, :null => false    
    if Rails.configuration.database_configuration[Rails.env]["adapter"] == 'oracle_enhanced'
      execute 'create unique index uk_ft_saf_transfers_01 on ft_saf_transfers (customer_id, req_no)'
      execute 'create index ft_saf_transfers_02 on ft_saf_transfers (trunc(req_timestamp), req_transfer_type, customer_id)'
    end  
  end
end
