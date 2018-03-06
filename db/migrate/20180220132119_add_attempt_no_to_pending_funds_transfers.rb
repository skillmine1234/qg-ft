class AddAttemptNoToPendingFundsTransfers < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists? 'funds_transfers'
      add_column :pending_funds_transfers, :attempt_no, :integer, comment: 'the attempt number of the requery'
    end
  end
end
