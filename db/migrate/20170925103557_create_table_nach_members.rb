class CreateTableNachMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :nach_members do |t|# , {:sequence_start_value => '1 cache 20 order increment by 1'} do |t|
      t.string :iin, limit: 50, null: false, comment: 'the IIN of the bank'
      t.string :name, limit: 50, null: false, comment: 'the name of the bank'
      t.datetime :created_at, null: false, comment: "the timestamp when the record was created"
      t.datetime :updated_at, null: false, comment: "the timestamp when the record was last updated"
      t.string :created_by, limit: 20, comment: "the person who creates the record"
      t.string :updated_by, limit: 20, comment: "the person who updates the record"
      t.integer :lock_version, null: false, default: 0, comment: "the version number of the record, every update increments this by 1"
      t.string :last_action, limit: 1, default: 'C', null: false, comment: "the last action (create, update) that was performed on the record"
      t.string :approval_status, limit: 1, default: 'U', null: false, comment: "the indicator to denote whether this record is pending approval or is approved" 
      t.integer :approved_version, comment: "the version number of the record, at the time it was approved"
      t.integer :approved_id, comment: "the id of the record that is being updated"      
      t.string :is_enabled, limit: 1, :null => false, :default => 'N', comment: 'the flag which indicates whether this bank is enabled or not'           
      t.index([:iin, :approval_status], unique: true, name: 'nach_members_01')
    end
  end
end