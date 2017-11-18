class IndexModificationInFtSafTransfers < ActiveRecord::Migration
  def change
    remove_index :ft_saf_transfers, name: 'ft_saf_transfers_02'
    add_index :ft_saf_transfers, [:req_timestamp, :customer_id, :req_transfer_type], :name => "ft_saf_transfers_02"        
  end
end
