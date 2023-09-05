require 'spec_helper'

describe FtCustomerAccountsHelper do
  include HelperMethods

  before(:each) do
    mock_ldap
  end

  context "find_ft_customer_accounts" do
    it "should find ft_customer_accounts" do      
      ft_customer_account = Factory(:ft_customer_account, :customer_id => Factory(:funds_transfer_customer, :customer_id => '12345', :enabled => 'Y', :approval_status => 'A').customer_id, :approval_status => "A")
      find_ft_customer_accounts({:customer_id => '12345'}).should == [ft_customer_account]
      find_ft_customer_accounts({:customer_id => '123456'}).should == []
    end
  end
end
