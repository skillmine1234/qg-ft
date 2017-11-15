class ModifyIndexInFtSafTransfers < ActiveRecord::Migration
  def change
    if Rails.configuration.database_configuration[Rails.env]["adapter"] == 'oracle_enhanced'
      execute 'drop index uk_ft_saf_transfers_02'
      execute 'create index ft_saf_transfers_02 on ft_saf_transfers (trunc(req_timestamp), req_transfer_type, customer_id)'
    end    
  end
end
