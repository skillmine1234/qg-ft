require 'spec_helper'
require "cancan_matcher"

describe FtPurgeSafTransfersController do
  include HelperMethods

  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "assigns all ft_purge_saf_transfers as @ft_purge_saf_transfers" do
      ft_purge_saf_transfer = Factory(:ft_purge_saf_transfer, :approval_status => 'A')
      get :index
      assigns(:records).should eq([ft_purge_saf_transfer])
    end
    it "assigns all unapproved ft_purge_saf_transfers as @ft_purge_saf_transfers when approval_status is passed" do
      ft_purge_saf_transfer = Factory(:ft_purge_saf_transfer, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:records).should eq([ft_purge_saf_transfer])
    end
  end

  describe "GET show" do
    it "assigns the requested ft_purge_saf_transfer as @ft_purge_saf_transfer" do
      ft_purge_saf_transfer = Factory(:ft_purge_saf_transfer)
      get :show, {:id => ft_purge_saf_transfer.id}
      assigns(:ft_purge_saf_transfer).should eq(ft_purge_saf_transfer)
    end
  end

  describe "GET new" do
    it "assigns a new ft_purge_saf_transfer as @ft_purge_saf_transfer" do
      get :new
      assigns(:ft_purge_saf_transfer).should be_a_new(FtPurgeSafTransfer)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ft_purge_saf_transfer" do
        params = Factory.attributes_for(:ft_purge_saf_transfer)
        expect {
          post :create, {:ft_purge_saf_transfer => params}
        }.to change(FtPurgeSafTransfer.unscoped, :count).by(1)
        flash[:alert].should  match(/Record successfully created and is pending for approval/)
        response.should be_redirect
      end

      it "assigns a newly created ft_purge_saf_transfer as @ft_purge_saf_transfer" do
        params = Factory.attributes_for(:ft_purge_saf_transfer)
        post :create, {:ft_purge_saf_transfer => params}
        assigns(:ft_purge_saf_transfer).should be_a(FtPurgeSafTransfer)
        assigns(:ft_purge_saf_transfer).should be_persisted
      end

      it "redirects to the created ft_purge_saf_transfer" do
        params = Factory.attributes_for(:ft_purge_saf_transfer)
        post :create, {:ft_purge_saf_transfer => params}
        response.should redirect_to(FtPurgeSafTransfer.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved ft_purge_saf_transfer as @ft_purge_saf_transfer" do
        params = Factory.attributes_for(:ft_purge_saf_transfer)
        params[:from_req_timestamp] = nil
        expect {
          post :create, {:ft_purge_saf_transfer => params}
        }.to change(FtPurgeSafTransfer, :count).by(0)
        assigns(:ft_purge_saf_transfer).should be_a(FtPurgeSafTransfer)
        assigns(:ft_purge_saf_transfer).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:ft_purge_saf_transfer)
        params[:from_req_timestamp] = nil
        post :create, {:ft_purge_saf_transfer => params}
        response.should render_template("new")
      end
    end
  end
  
  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      ft_purge_saf_transfer1 = Factory(:ft_purge_saf_transfer, :approval_status => 'A')
      ft_purge_saf_transfer2 = Factory(:ft_purge_saf_transfer, :customer_id => 'BarFoo', :approval_status => 'U', :approved_version => ft_purge_saf_transfer1.lock_version, :approved_id => ft_purge_saf_transfer1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      ft_purge_saf_transfer1.approval_status.should == 'A'
      FtUnapprovedRecord.count.should == 1
      put :approve, {:id => ft_purge_saf_transfer2.id}
      FtUnapprovedRecord.count.should == 0
      ft_purge_saf_transfer1.reload
      ft_purge_saf_transfer1.customer_id.should == 'BarFoo'
      ft_purge_saf_transfer1.updated_by.should == "666"
      FtPurgeSafTransfer.find_by_id(ft_purge_saf_transfer2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      ft_purge_saf_transfer = Factory(:ft_purge_saf_transfer, :customer_id => 'BarFoo', :approval_status => 'U')
      FtUnapprovedRecord.count.should == 1
      put :approve, {:id => ft_purge_saf_transfer.id}
      FtUnapprovedRecord.count.should == 0
      ft_purge_saf_transfer.reload
      ft_purge_saf_transfer.customer_id.should == 'BarFoo'
      ft_purge_saf_transfer.approval_status.should == 'A'
    end
  end
  
end