class CreateFtTmpAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :ft_tmp_audit_logs do |t|#,# {:sequence_start_value => '1 cache 20 order increment by 1'}  do |t|
      t.string :req_no, :limit => 50, :null => false, :comment => "the unique request number for the transaction"
      t.string :app_id, :limit => 20, :null => false, :comment => "the unique id assigned to a client app"
      t.string :customer_id, :limit => 15, :null => false, :comment  => "the ID of the customer"
      t.integer :ft_invoice_detail_id, :comment => "the name of the table that represents the request that is related to this record"
      t.datetime :created_at, :null => false, :comment => "the timestamp when the record was created"
      t.text :req_bitstream, :comment => 'the full request payload as received from the client'
    end
    add_index :ft_tmp_audit_logs, [:ft_invoice_detail_id, :req_no, :app_id, :customer_id], :unique => true, :name => "ft_tmp_audit_logs_01"
  end
end
