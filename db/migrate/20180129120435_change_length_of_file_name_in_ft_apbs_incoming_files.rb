class ChangeLengthOfFileNameInFtApbsIncomingFiles < ActiveRecord::Migration
  def change
    change_column :ft_apbs_incoming_files, :file_name, :string, limit: 100
  end
end