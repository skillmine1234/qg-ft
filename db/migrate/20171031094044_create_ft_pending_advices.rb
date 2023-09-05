class CreateFtPendingAdvices < ActiveRecord::Migration[7.0]
  def change
    create_table :ft_pending_advices do |t|#, {:sequence_start_value => '1 cache 20 order increment by 1'}  do |t|
      t.string :broker_uuid, :limit => 255, :null => false, :comment => "the UUID of the broker"
      t.integer :ft_invoice_detail_id, :null => false, :comment => 'the id of the funds transfers invioce detail table'
      t.integer :funds_transfer_id,  :comment => 'the id of the funds transfer record'
      t.datetime :created_at, :null => false, :comment => "the timestamp when the record was created"
    end
    add_index :ft_pending_advices, [:ft_invoice_detail_id, :funds_transfer_id], :unique => true, :name => "ft_pending_advices_01"
  end
end
