class AddColumnsInFtSafTransfers < ActiveRecord::Migration
  def change
      add_column :ft_saf_transfers, :transfer_amount, :number, :comment => "the amount which has been requested to transfer to the beneficiary"
      add_column :ft_saf_transfers, :transfer_ccy, :string, :limit => 5, :comment => "the transfer currency code"
  end
end
