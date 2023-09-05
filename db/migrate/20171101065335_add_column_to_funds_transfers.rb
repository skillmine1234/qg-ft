class AddColumnToFundsTransfers < ActiveRecord::Migration[7.0]
  def change
    if ActiveRecord::Base.connection.table_exists? 'funds_transfers'
      add_column :funds_transfers, :ft_invoice_detail_id, :integer, comment: 'the id of the funds transfers invioce detail table'
    end
  end
end
