class CreateTableFtApbsOutgoingFiles < ActiveRecord::Migration
  def change
    create_table :ft_apbs_outgoing_files, {:sequence_start_value => "1 cache 20 order increment by 1"}  do |t|
      t.string :customer_id, :limit => 15, :comment => 'The id of the customer'
      t.number :serial_no, :comment => "The serial number for the present day"  
      t.date :creation_date, :comment => "The system Date"         
    end
    add_index :ft_apbs_outgoing_files, [:customer_id, :serial_no, :creation_date], :unique => true, :name => "ft_apbs_outgoing_files_01"    
  end
end