require 'spec_helper'

describe FtCustomerAccountsController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
    
    mock_ldap
  end

  describe "GET index" do
    it "assigns all ft_customer_accounts as @ft_customer_accounts" do
      ft_customer_account = Factory(:ft_customer_account, :approval_status => 'A')
      get :index
      assigns(:ft_customer_accounts).should eq([ft_customer_account])
    end

    it "assigns all unapproved ft_customer_accounts as @ft_customer_accounts when approval_status is passed" do
      ft_customer_account = Factory(:ft_customer_account, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:ft_customer_accounts).should eq([ft_customer_account])
    end
  end

  describe "GET show" do
    it "assigns the requested ft_customer_account as @ft_customer_account" do
      ft_customer_account = Factory(:ft_customer_account)
      get :show, {:id => ft_customer_account.id}
      assigns(:ft_customer_account).should eq(ft_customer_account)
    end
  end

  describe "GET new" do
    it "assigns a new ft_customer_account as @ft_customer_account" do
      get :new
      assigns(:ft_customer_account).should be_a_new(FtCustomerAccount)
    end
  end

  describe "GET edit" do
    it "assigns the requested ft_customer_account with status 'U' as @ft_customer_account" do
      ft_customer_account = Factory(:ft_customer_account, :approval_status => 'U')
      get :edit, {:id => ft_customer_account.id}
      assigns(:ft_customer_account).should eq(ft_customer_account)
    end

    it "assigns the requested ft_customer_account with status 'A' as @ft_customer_account" do
      ft_customer_account = Factory(:ft_customer_account,:approval_status => 'A')
      get :edit, {:id => ft_customer_account.id}
      assigns(:ft_customer_account).should eq(ft_customer_account)
    end

    it "assigns the new ft_customer_account with requested ft_customer_account params when status 'A' as @ft_customer_account" do
      ft_customer_account = Factory(:ft_customer_account,:approval_status => 'A')
      params = (ft_customer_account.attributes).merge({:approved_id => ft_customer_account.id,:approved_version => ft_customer_account.lock_version})
      get :edit, {:id => ft_customer_account.id}
      assigns(:ft_customer_account).should eq(FtCustomerAccount.new(params))
    end
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "creates a new ft_customer_account" do
        params = Factory.attributes_for(:ft_customer_account)
        expect {
          post :create, {:ft_customer_account => params}
        }.to change(FtCustomerAccount.unscoped, :count).by(1)
        flash[:alert].should  match(/Customer Account successfully created and is pending for approval/)
        response.should be_redirect
      end

      it "assigns a newly created ft_customer_account as @ft_customer_account" do
        params = Factory.attributes_for(:ft_customer_account)
        post :create, {:ft_customer_account => params}
        assigns(:ft_customer_account).should be_a(FtCustomerAccount)
        assigns(:ft_customer_account).should be_persisted
      end

      it "redirects to the created ft_customer_account" do
        params = Factory.attributes_for(:ft_customer_account)
        post :create, {:ft_customer_account => params}
        response.should redirect_to(FtCustomerAccount.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved ft_customer_account as @ft_customer_account" do
        params = Factory.attributes_for(:ft_customer_account)
        params[:account_no] = nil
        expect {
          post :create, {:ft_customer_account => params}
        }.to change(FtCustomerAccount, :count).by(0)
        assigns(:ft_customer_account).should be_a(FtCustomerAccount)
        assigns(:ft_customer_account).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:ft_customer_account)
        params[:account_no] = nil
        post :create, {:ft_customer_account => params}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested ft_customer_account" do
        ft_customer_account = Factory(:ft_customer_account, :account_no => "012323")
        params = ft_customer_account.attributes.slice(*ft_customer_account.class.attribute_names)
        params[:account_no] = "12345"
        put :update, {:id => ft_customer_account.id, :ft_customer_account => params}
        ft_customer_account.reload
        ft_customer_account.account_no.should == "12345"
      end

      it "assigns the requested ft_customer_account as @ft_customer_account" do
        ft_customer_account = Factory(:ft_customer_account, :account_no => "12345")
        params = ft_customer_account.attributes.slice(*ft_customer_account.class.attribute_names)
        params[:account_no] = "123456"
        put :update, {:id => ft_customer_account.to_param, :ft_customer_account => params}
        assigns(:ft_customer_account).should eq(ft_customer_account)
      end

      it "redirects to the ft_customer_account" do
        ft_customer_account = Factory(:ft_customer_account, :account_no => "12345")
        params = ft_customer_account.attributes.slice(*ft_customer_account.class.attribute_names)
        params[:account_no] = "12345"
        put :update, {:id => ft_customer_account.to_param, :ft_customer_account => params}
        response.should redirect_to(ft_customer_account)
      end

      it "should raise error when tried to update at same time by many" do
        ft_customer_account = Factory(:ft_customer_account, :account_no => "12345")
        params = ft_customer_account.attributes.slice(*ft_customer_account.class.attribute_names)
        params[:account_no] = "123456"
        ft_customer_account2 = ft_customer_account
        put :update, {:id => ft_customer_account.id, :ft_customer_account => params}
        ft_customer_account.reload
        ft_customer_account.account_no.should == "123456"
        params[:account_no] = "1234567"
        put :update, {:id => ft_customer_account2.id, :ft_customer_account => params}
        ft_customer_account.reload
        ft_customer_account.account_no.should == "123456"
        flash[:alert].should  match(/Someone edited the Customer Account the same time you did. Please re-apply your changes to the Customer/)
      end
    end

    describe "with invalid params" do
      it "assigns the ft_customer_account as @ft_customer_account" do
        ft_customer_account = Factory(:ft_customer_account, :account_no => "12345")
        params = ft_customer_account.attributes.slice(*ft_customer_account.class.attribute_names)
        params[:account_no] = nil
        put :update, {:id => ft_customer_account.to_param, :ft_customer_account => params}
        assigns(:ft_customer_account).should eq(ft_customer_account)
        ft_customer_account.reload
        params[:account_no] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        ft_customer_account = Factory(:ft_customer_account)
        params = ft_customer_account.attributes.slice(*ft_customer_account.class.attribute_names)
        params[:account_no] = nil
        put :update, {:id => ft_customer_account.id, :ft_customer_account => params}
        response.should render_template("edit")
      end
    end
  end
 
  describe "GET audit_logs" do
    it "assigns the requested ft_customer_account as @ft_customer_account" do
      ft_customer_account = Factory(:ft_customer_account)
      get :audit_logs, {:id => ft_customer_account.id, :version_id => 0}
      assigns(:ft_customer_account).should eq(ft_customer_account)
      assigns(:audit).should eq(ft_customer_account.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:ft_customer_account).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end

  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      ft_customer_account1 = Factory(:ft_customer_account, :approval_status => 'A')
      ft_customer_account2 = Factory(:ft_customer_account, :approval_status => 'U', :account_no => '12345', :approved_version => ft_customer_account1.lock_version, :approved_id => ft_customer_account1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      ft_customer_account1.approval_status.should == 'A'
      FtUnapprovedRecord.count.should == 1
      put :approve, {:id => ft_customer_account2.id}
      FtUnapprovedRecord.count.should == 0
      ft_customer_account1.reload
      ft_customer_account1.account_no.should == '12345'
      ft_customer_account1.updated_by.should == "666"
      FtCustomerAccount.find_by_id(ft_customer_account2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      ft_customer_account = Factory(:ft_customer_account, :account_no => '12345', :approval_status => 'U')
      FtUnapprovedRecord.count.should == 1
      put :approve, {:id => ft_customer_account.id}
      FtUnapprovedRecord.count.should == 0
      ft_customer_account.reload
      ft_customer_account.account_no.should == '12345'
      ft_customer_account.approval_status.should == 'A'
    end
  end
end
