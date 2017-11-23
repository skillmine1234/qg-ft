class AddColumnFileRefNoToFtApbsIncomingRecords < ActiveRecord::Migration
  def change
    add_column :ft_apbs_incoming_records, :file_ref_no, :string, limit: 20, comment: 'the reference no for the file which comes in header.' 
  end
end
