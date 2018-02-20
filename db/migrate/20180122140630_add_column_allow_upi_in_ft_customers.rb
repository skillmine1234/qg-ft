class AddColumnAllowUpiInFtCustomers < ActiveRecord::Migration
  def change
    add_column :ft_customers, :allow_upi, :string, :limit => 1, null: false, default: 'N', comment: 'the identifier to specify if upi transaction is allowed or not to the customer' 
  end
end
