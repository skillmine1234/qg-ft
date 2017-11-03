require 'spec_helper'

describe FundsTransferCustomersController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
    
    mock_ldap
  end

  describe "GET index" do
    it "assigns all funds_transfer_customers as @funds_transfer_customers" do
      funds_transfer_customer = Factory(:funds_transfer_customer, :approval_status => 'A')
      get :index
      assigns(:funds_transfer_customers).should eq([funds_transfer_customer])
    end

    it "assigns all unapproved funds_transfer_customers as @funds_transfer_customers when approval_status is passed" do
      funds_transfer_customer = Factory(:funds_transfer_customer, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:funds_transfer_customers).should eq([funds_transfer_customer])
    end
  end

  describe "GET show" do
    it "assigns the requested funds_transfer_customer as @funds_transfer_customer" do
      funds_transfer_customer = Factory(:funds_transfer_customer)
      get :show, {:id => funds_transfer_customer.id}
      assigns(:funds_transfer_customer).should eq(funds_transfer_customer)
    end
  end

  describe "GET new" do
    it "assigns a new funds_transfer_customer as @funds_transfer_customer" do
      get :new
      assigns(:funds_transfer_customer).should be_a_new(FundsTransferCustomer)
    end
  end

  describe "GET edit" do
    it "assigns the requested funds_transfer_customer with status 'U' as @funds_transfer_customer" do
      funds_transfer_customer = Factory(:funds_transfer_customer, :approval_status => 'U')
      get :edit, {:id => funds_transfer_customer.id}
      assigns(:funds_transfer_customer).should eq(funds_transfer_customer)
    end

    it "assigns the requested funds_transfer_customer with status 'A' as @funds_transfer_customer" do
      funds_transfer_customer = Factory(:funds_transfer_customer,:approval_status => 'A')
      get :edit, {:id => funds_transfer_customer.id}
      assigns(:funds_transfer_customer).should eq(funds_transfer_customer)
    end

    it "assigns the new funds_transfer_customer with requested funds_transfer_customer params when status 'A' as @funds_transfer_customer" do
      funds_transfer_customer = Factory(:funds_transfer_customer,:approval_status => 'A')
      params = (funds_transfer_customer.attributes).merge({:approved_id => funds_transfer_customer.id,:approved_version => funds_transfer_customer.lock_version})
      get :edit, {:id => funds_transfer_customer.id}
      assigns(:funds_transfer_customer).should eq(FundsTransferCustomer.new(params))
    end
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "creates a new funds_transfer_customer" do
        params = Factory.attributes_for(:funds_transfer_customer)
        expect {
          post :create, {:funds_transfer_customer => params}
        }.to change(FundsTransferCustomer.unscoped, :count).by(1)
        flash[:alert].should  match(/Customer successfully created and is pending for approval/)
        response.should be_redirect
      end

      it "assigns a newly created funds_transfer_customer as @funds_transfer_customer" do
        params = Factory.attributes_for(:funds_transfer_customer)
        post :create, {:funds_transfer_customer => params}
        assigns(:funds_transfer_customer).should be_a(FundsTransferCustomer)
        assigns(:funds_transfer_customer).should be_persisted
      end

      it "redirects to the created funds_transfer_customer" do
        params = Factory.attributes_for(:funds_transfer_customer)
        post :create, {:funds_transfer_customer => params}
        response.should redirect_to(FundsTransferCustomer.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved funds_transfer_customer as @funds_transfer_customer" do
        params = Factory.attributes_for(:funds_transfer_customer)
        params[:app_id] = nil
        expect {
          post :create, {:funds_transfer_customer => params}
        }.to change(FundsTransferCustomer, :count).by(0)
        assigns(:funds_transfer_customer).should be_a(FundsTransferCustomer)
        assigns(:funds_transfer_customer).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:funds_transfer_customer)
        params[:app_id] = nil
        post :create, {:funds_transfer_customer => params}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested funds_transfer_customer" do
        funds_transfer_customer = Factory(:funds_transfer_customer, :name => "CUST01")
        params = funds_transfer_customer.attributes.slice(*funds_transfer_customer.class.attribute_names)
        params[:name] = "CUST02"
        put :update, {:id => funds_transfer_customer.id, :funds_transfer_customer => params}
        funds_transfer_customer.reload
        funds_transfer_customer.name.should == "CUST02"
      end

      it "assigns the requested funds_transfer_customer as @funds_transfer_customer" do
        funds_transfer_customer = Factory(:funds_transfer_customer, :name => "CUST01")
        params = funds_transfer_customer.attributes.slice(*funds_transfer_customer.class.attribute_names)
        params[:name] = "CUST02"
        put :update, {:id => funds_transfer_customer.to_param, :funds_transfer_customer => params}
        assigns(:funds_transfer_customer).should eq(funds_transfer_customer)
      end

      it "redirects to the funds_transfer_customer" do
        funds_transfer_customer = Factory(:funds_transfer_customer, :name => "CUST01")
        params = funds_transfer_customer.attributes.slice(*funds_transfer_customer.class.attribute_names)
        params[:name] = "CUST02"
        put :update, {:id => funds_transfer_customer.to_param, :funds_transfer_customer => params}
        response.should redirect_to(funds_transfer_customer)
      end

      it "should raise error when tried to update at same time by many" do
        funds_transfer_customer = Factory(:funds_transfer_customer, :name => "CUST01")
        params = funds_transfer_customer.attributes.slice(*funds_transfer_customer.class.attribute_names)
        params[:name] = "CUST02"
        funds_transfer_customer2 = funds_transfer_customer
        put :update, {:id => funds_transfer_customer.id, :funds_transfer_customer => params}
        funds_transfer_customer.reload
        funds_transfer_customer.name.should == "CUST02"
        params[:name] = "CUST03"
        put :update, {:id => funds_transfer_customer2.id, :funds_transfer_customer => params}
        funds_transfer_customer.reload
        funds_transfer_customer.name.should == "CUST02"
        flash[:alert].should  match(/Someone edited the Customer the same time you did. Please re-apply your changes to the Customer/)
      end
    end

    describe "with invalid params" do
      it "assigns the funds_transfer_customer as @funds_transfer_customer" do
        funds_transfer_customer = Factory(:funds_transfer_customer, :name => "CUST01")
        params = funds_transfer_customer.attributes.slice(*funds_transfer_customer.class.attribute_names)
        params[:name] = nil
        put :update, {:id => funds_transfer_customer.to_param, :funds_transfer_customer => params}
        assigns(:funds_transfer_customer).should eq(funds_transfer_customer)
        funds_transfer_customer.reload
        params[:name] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        funds_transfer_customer = Factory(:funds_transfer_customer)
        params = funds_transfer_customer.attributes.slice(*funds_transfer_customer.class.attribute_names)
        params[:app_id] = nil
        put :update, {:id => funds_transfer_customer.id, :funds_transfer_customer => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end
 
  describe "GET audit_logs" do
    it "assigns the requested funds_transfer_customer as @funds_transfer_customer" do
      funds_transfer_customer = Factory(:funds_transfer_customer)
      get :audit_logs, {:id => funds_transfer_customer.id, :version_id => 0}
      assigns(:funds_transfer_customer).should eq(funds_transfer_customer)
      assigns(:audit).should eq(funds_transfer_customer.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:funds_transfer_customer).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end

  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      funds_transfer_customer1 = Factory(:funds_transfer_customer, :approval_status => 'A')
      funds_transfer_customer2 = Factory(:funds_transfer_customer, :approval_status => 'U', :name => 'Bar Foo', :approved_version => funds_transfer_customer1.lock_version, :approved_id => funds_transfer_customer1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      funds_transfer_customer1.approval_status.should == 'A'
      FtUnapprovedRecord.count.should == 1
      put :approve, {:id => funds_transfer_customer2.id}
      FtUnapprovedRecord.count.should == 0
      funds_transfer_customer1.reload
      funds_transfer_customer1.name.should == 'BAR FOO'
      funds_transfer_customer1.updated_by.should == "666"
      FundsTransferCustomer.find_by_id(funds_transfer_customer2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      funds_transfer_customer = Factory(:funds_transfer_customer, :name => 'Bar Foo', :approval_status => 'U')
      FtUnapprovedRecord.count.should == 1
      put :approve, {:id => funds_transfer_customer.id}
      FtUnapprovedRecord.count.should == 0
      funds_transfer_customer.reload
      funds_transfer_customer.name.should == 'BAR FOO'
      funds_transfer_customer.approval_status.should == 'A'
    end
  end
end
