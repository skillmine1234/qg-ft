require 'spec_helper'

describe FtUnapprovedRecordsController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "assigns all ft_unapproved_records as @ft_unapproved_records" do
      ft_unapproved_record = Factory(:ft_unapproved_record, :ft_approvable_type => 'FundsTransferCustomer')
      get :index
      assigns(:records).should eq([{:record_type=>"FundsTransferCustomer", :record_count=>1}, {:record_type=>"FtPurposeCode", :record_count=>0}, {:record_type=>"IncomingFile", :record_count=>0}, {:record_type=>"FtCustomerAccount", :record_count=>0}, {:record_type=>"FtPurgeSafTransfer", :record_count=>0}, {:record_type=>"NachMember", :record_count=>0}])
    end
  end
end
