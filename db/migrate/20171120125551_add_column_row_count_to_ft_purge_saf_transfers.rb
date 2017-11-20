class AddColumnRowCountToFtPurgeSafTransfers < ActiveRecord::Migration
  def change
    add_column :ft_purge_saf_transfers, :row_count, :integer, comment: 'the no. of rows that have been deleted when this record was approved'
  end
end
