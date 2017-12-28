class CreateFtInvoiceDetails < ActiveRecord::Migration
  def change
    create_table :ft_invoice_details, {:sequence_start_value => '1 cache 20 order increment by 1'}  do |t|
      t.string :req_no, :limit => 50, :null => false, :comment => "the unique request number for the transaction"
      t.string :req_version, :limit => 10, :null => false, :comment => "the request version"
      t.datetime :req_timestamp, :null => false, :comment => "the request timestamp"
      t.string :app_id, :limit => 20, :null => false, :comment => "the unique id assigned to a client app"
      t.string :customer_id, :limit => 15, :null => false, :comment  => "the ID of the customer"
      t.string :customer_name, :limit => 50, :comment  => "the name of the customer"
      t.string :status_code, :limit => 50, :null => false, :comment  => "the status of this request"
      t.integer :attempt_no, :null => false, :comment => "the attempt number of the request, failed requests can be retried"
      t.string :supplier_code, :limit => 20, :comment  => "The Code Assigned to the supplier by the customer"
      t.string :purchase_order_number, :limit => 50, :comment  => "The list of invoices paid (one payment can be made for multiple invoices). The sum of paidAmount should match transferAmount"
      t.string :invoice_number, :limit => 50, :comment  => "The Invoice Number"
      t.datetime :invoice_date, :comment => "The Invoice Date"
      t.number :invoice_amount, :comment => "The invoiced amount, this is what the supplier has asked for"
      t.number :retained_amount, :comment => "The amount deducted (not paid) by the customer"
      t.number :deducted_amount, :comment => "The amount deducted (not paid) by the customer"   
      t.number :tds_amount, :comment => "The amount deducted at source by the customer"
      t.number :paid_amount, :comment => "The amount paid towards this invoice"
      t.string :payment_reference, :limit => 255, :comment  => "The payment reference for this invoice (different than the UTR for the payment)"
      t.string :note, :limit => 255, :comment  => "A free format note for the invoice"
      t.number :cgst_amount, :comment => "The Central GST dedusted by the customer if any"
      t.number :sgst_amount, :comment => "The State GST deducted by the customer if any"
      t.number :igst_amount, :comment => "The Inter State GST deducted by customer if any"
      t.string :gstin, :limit => 50, :comment  => "Customer GSTIN number ,GST registration number"
      t.string :advice_file_name, :limit => 100, :comment  => "the name of the advice file"
      t.string :cnb_file_name, :limit => 100, :comment  => "the name of the cnb file"
      t.string :advice_status, :limit => 50, :comment  => "the status of the advice"
      t.string :advice_email_id, :limit => 100, :comment  => "the email id on which advice has been sent"
      t.datetime :advice_sent_at, :comment  => "the timestamp when advice has been sent"
      t.integer :funds_transfer_id, :comment => "the id for the transfer in funds transfers table"
      t.string :rep_no,:limit => 50, :comment => "the unique response no sent by API"
      t.string :rep_version, :limit => 10, :comment => " the number comes in the reply, this reflects the version that is known to the server"
      t.datetime :rep_timestamp, :comment => "the SYSDATE when the reply was sent to the client"
      t.string :fault_code, :limit => 50, :comment => "the code that identifies the business failure reason/exception"
      t.string :fault_reason, :limit => 1000, :comment => "the english reason of the business failure reason/exception"
    end
    add_index :ft_invoice_details, [:customer_id, :req_no, :attempt_no], :unique => true, :name => "ft_invoice_details_01"
  end
end
