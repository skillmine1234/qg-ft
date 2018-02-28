class AddAttemptNoToPendingFundsTransfers < ActiveRecord::Migration
  def change
    add_column :pending_funds_transfers, :attempt_no, :integer, comment: 'the attempt number of the requery'             
  end
end
