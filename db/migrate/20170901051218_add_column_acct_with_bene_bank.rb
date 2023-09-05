class AddColumnAcctWithBeneBank < ActiveRecord::Migration[7.0]
  def change
    if ActiveRecord::Base.connection.table_exists? 'funds_transfers'
      add_column :funds_transfers, :acct_with_bene_bank, :string, limit: 20, comment: "the credited account number which is presented in aadhaar linked bank"    
    end
  end
end
