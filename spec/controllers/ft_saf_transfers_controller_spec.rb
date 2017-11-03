require 'spec_helper'

describe FtSafTransfersController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "should assign all ft_saf_transfers as @ft_saf_transfers" do
      ft_saf_transfer = Factory(:ft_saf_transfer)
      get :index
      assigns(:records).should eq([ft_saf_transfer])
    end
  end

  describe "GET show" do
    it "should assign the requested ft_saf_transfer as @ft_saf_transfer" do
      ft_saf_transfer = Factory(:ft_saf_transfer)
      get :show, {:id => ft_saf_transfer.id}
      assigns(:ft_saf_transfer).should eq(ft_saf_transfer)
    end
  end
  
  describe "destroy" do
    it "should destroy the ft_saf_transfer" do 
      ft_saf_transfer = Factory(:ft_saf_transfer)
      delete :destroy, {:id => ft_saf_transfer.id}
      FtSafTransfer.find_by_id(ft_saf_transfer.id).should be_nil
    end
  end
end
