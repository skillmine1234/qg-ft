require 'spec_helper'
require "cancan_matcher"

describe FtPurposeCodesController do
  include HelperMethods

  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "assigns all ft_purpose_codes as @ft_purpose_codes" do
      ft_purpose_code = Factory(:ft_purpose_code, :approval_status => 'A')
      get :index
      assigns(:ft_purpose_codes).should eq([ft_purpose_code])
    end
    it "assigns all unapproved ft_purpose_codes as @ft_purpose_codes when approval_status is passed" do
      ft_purpose_code = Factory(:ft_purpose_code, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:ft_purpose_codes).should eq([ft_purpose_code])
    end
  end

  describe "GET show" do
    it "assigns the requested ft_purpose_code as @ft_purpose_code" do
      ft_purpose_code = Factory(:ft_purpose_code)
      get :show, {:id => ft_purpose_code.id}
      assigns(:ft_purpose_code).should eq(ft_purpose_code)
    end
  end

  describe "GET new" do
    it "assigns a new ft_purpose_code as @ft_purpose_code" do
      get :new
      assigns(:ft_purpose_code).should be_a_new(FtPurposeCode)
    end
  end

  describe "GET edit" do
    it "assigns the requested ft_purpose_code as @ft_purpose_code" do
      ft_purpose_code = Factory(:ft_purpose_code)
      get :edit, {:id => ft_purpose_code.id}
      assigns(:ft_purpose_code).should eq(ft_purpose_code)
    end
    
    it "assigns the requested ft_purpose_code with status 'A' as @ft_purpose_code" do
      ft_purpose_code = Factory(:ft_purpose_code,:approval_status => 'A')
      get :edit, {:id => ft_purpose_code.id}
      assigns(:ft_purpose_code).should eq(ft_purpose_code)
    end

    it "assigns the new customer with requested ft_purpose_code params when status 'A' as @ft_purpose_code" do
      ft_purpose_code = Factory(:ft_purpose_code,:approval_status => 'A')
      params = (ft_purpose_code.attributes).merge({:approved_id => ft_purpose_code.id,:approved_version => ft_purpose_code.lock_version})
      get :edit, {:id => ft_purpose_code.id}
      assigns(:ft_purpose_code).should eq(FtPurposeCode.new(params))
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ft_purpose_code" do
        params = Factory.attributes_for(:ft_purpose_code)
        expect {
          post :create, {:ft_purpose_code => params}
        }.to change(FtPurposeCode.unscoped, :count).by(1)
        flash[:alert].should  match(/FT Purpose Code successfully created/)
        response.should be_redirect
      end

      it "assigns a newly created ft_purpose_code as @ft_purpose_code" do
        params = Factory.attributes_for(:ft_purpose_code)
        post :create, {:ft_purpose_code => params}
        assigns(:ft_purpose_code).should be_a(FtPurposeCode)
        assigns(:ft_purpose_code).should be_persisted
      end

      it "redirects to the created ft_purpose_code" do
        params = Factory.attributes_for(:ft_purpose_code)
        post :create, {:ft_purpose_code => params}
        response.should redirect_to(FtPurposeCode.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved ft_purpose_code as @ft_purpose_code" do
        params = Factory.attributes_for(:ft_purpose_code)
        params[:code] = nil
        expect {
          post :create, {:ft_purpose_code => params}
        }.to change(FtPurposeCode, :count).by(0)
        assigns(:ft_purpose_code).should be_a(FtPurposeCode)
        assigns(:ft_purpose_code).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:ft_purpose_code)
        params[:code] = nil
        post :create, {:ft_purpose_code => params}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested ft_purpose_code" do
        ft_purpose_code = Factory(:ft_purpose_code, :code => "1111")
        params = ft_purpose_code.attributes.slice(*ft_purpose_code.class.attribute_names)
        params[:code] = "1555"
        put :update, {:id => ft_purpose_code.id, :ft_purpose_code => params}
        ft_purpose_code.reload
        ft_purpose_code.code.should == "1555"
      end

      it "assigns the requested ft_purpose_code as @ft_purpose_code" do
        ft_purpose_code = Factory(:ft_purpose_code, :code => "1111")
        params = ft_purpose_code.attributes.slice(*ft_purpose_code.class.attribute_names)
        params[:code] = "1555"
        put :update, {:id => ft_purpose_code.to_param, :ft_purpose_code => params}
        assigns(:ft_purpose_code).should eq(ft_purpose_code)
      end

      it "redirects to the ft_purpose_code" do
        ft_purpose_code = Factory(:ft_purpose_code, :code => "1111")
        params = ft_purpose_code.attributes.slice(*ft_purpose_code.class.attribute_names)
        params[:code] = "1555"
        put :update, {:id => ft_purpose_code.to_param, :ft_purpose_code => params}
        response.should redirect_to(ft_purpose_code)
      end

      it "should raise error when tried to update at same time by many" do
        ft_purpose_code = Factory(:ft_purpose_code, :code => "1111")
        params = ft_purpose_code.attributes.slice(*ft_purpose_code.class.attribute_names)
        params[:code] = "1555"
        ft_purpose_code2 = ft_purpose_code
        put :update, {:id => ft_purpose_code.id, :ft_purpose_code => params}
        ft_purpose_code.reload
        ft_purpose_code.code.should == "1555"
        params[:code] = "1888"
        put :update, {:id => ft_purpose_code2.id, :ft_purpose_code => params}
        ft_purpose_code.reload
        ft_purpose_code.code.should == "1555"
        flash[:alert].should  match(/Someone edited the ft_purpose_code the same time you did. Please re-apply your changes to the ft_purpose_code/)
      end
    end

    describe "with invalid params" do
      it "assigns the ft_purpose_code as @ft_purpose_code" do
        ft_purpose_code = Factory(:ft_purpose_code, :code => "1111")
        params = ft_purpose_code.attributes.slice(*ft_purpose_code.class.attribute_names)
        params[:code] = nil
        put :update, {:id => ft_purpose_code.to_param, :ft_purpose_code => params}
        assigns(:ft_purpose_code).should eq(ft_purpose_code)
        ft_purpose_code.reload
        params[:code] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        ft_purpose_code = Factory(:ft_purpose_code)
        params = ft_purpose_code.attributes.slice(*ft_purpose_code.class.attribute_names)
        params[:code] = nil
        put :update, {:id => ft_purpose_code.id, :ft_purpose_code => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end

  describe "GET audit_logs" do
    it "assigns the requested ft_purpose_code as @ft_purpose_code" do
      ft_purpose_code = Factory(:ft_purpose_code)
      get :audit_logs, {:id => ft_purpose_code.id, :version_id => 0}
      assigns(:ft_purpose_code).should eq(ft_purpose_code)
      assigns(:audit).should eq(ft_purpose_code.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:ft_purpose_code).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end
  
  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      ft_purpose_code1 = Factory(:ft_purpose_code, :approval_status => 'A')
      ft_purpose_code2 = Factory(:ft_purpose_code, :description => 'BarFoo', :approval_status => 'U', :approved_version => ft_purpose_code1.lock_version, :approved_id => ft_purpose_code1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      ft_purpose_code1.approval_status.should == 'A'
      FtUnapprovedRecord.count.should == 1
      put :approve, {:id => ft_purpose_code2.id}
      FtUnapprovedRecord.count.should == 0
      ft_purpose_code1.reload
      ft_purpose_code1.description.should == 'BarFoo'
      ft_purpose_code1.updated_by.should == "666"
      FtPurposeCode.find_by_id(ft_purpose_code2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      ft_purpose_code = Factory(:ft_purpose_code, :description => 'BarFoo', :approval_status => 'U')
      FtUnapprovedRecord.count.should == 1
      put :approve, {:id => ft_purpose_code.id}
      FtUnapprovedRecord.count.should == 0
      ft_purpose_code.reload
      ft_purpose_code.description.should == 'BarFoo'
      ft_purpose_code.approval_status.should == 'A'
    end
  end
  
end