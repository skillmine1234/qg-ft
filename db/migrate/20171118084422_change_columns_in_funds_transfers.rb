class ChangeColumnsInFundsTransfers < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists? 'funds_transfers'
      change_column :funds_transfers, :was_saf, :string, null: true, default: nil
      change_column :funds_transfers, :op_name, :string, null: true, default: nil
    end
  end
end
