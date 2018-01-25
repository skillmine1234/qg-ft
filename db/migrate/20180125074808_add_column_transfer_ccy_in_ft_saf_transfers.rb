class AddColumnTransferCcyInFtSafTransfers < ActiveRecord::Migration
  def change
      add_column :ft_saf_transfers, :transfer_ccy, :string, :limit => 255, :comment => "the transfer currency code"
  end
end
