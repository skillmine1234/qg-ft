class AddStatusCodeToFtPurgeSafTransfers < ActiveRecord::Migration
  def change
    add_column :ft_purge_saf_transfers, :status_code, :string, limit: 25, comment: 'the status_code for the purge record'
  end
end
