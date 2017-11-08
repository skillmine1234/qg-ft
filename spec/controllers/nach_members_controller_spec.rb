require 'spec_helper'
require "cancan_matcher"

describe NachMembersController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"    
  end

  describe "GET index" do
    it "assigns all nach_members as @nach_members" do
      nach_member = Factory(:nach_member, :approval_status => 'A')
      get :index
      assigns(:records).should eq([nach_member])
    end

    it "assigns all unapproved nach_members as @nach_members when approval_status is passed" do
      nach_member = Factory(:nach_member, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:records).should eq([nach_member])
    end
  end

  describe "GET show" do
    it "assigns the requested nach_member as @nach_member" do
      nach_member = Factory(:nach_member)
      get :show, {:id => nach_member.id}
      assigns(:nach_member).should eq(nach_member)
    end
  end

  describe "GET new" do
    it "assigns a new nach_member as @nach_member" do
      get :new
      assigns(:nach_member).should be_a_new(NachMember)
    end
  end

  describe "GET edit" do
    it "assigns the requested nach_member with status 'U' as @nach_member" do
      nach_member = Factory(:nach_member, :approval_status => 'U')
      get :edit, {:id => nach_member.id}
      assigns(:nach_member).should eq(nach_member)
    end

    it "assigns the requested nach_member with status 'A' as @nach_member" do
      nach_member = Factory(:nach_member,:approval_status => 'A')
      get :edit, {:id => nach_member.id}
      assigns(:nach_member).should eq(nach_member)
    end

    it "assigns the new nach_member with requested nach_member params when status 'A' as @nach_member" do
      nach_member = Factory(:nach_member,:approval_status => 'A')
      params = (nach_member.attributes).merge({:approved_id => nach_member.id,:approved_version => nach_member.lock_version})
      get :edit, {:id => nach_member.id}
      assigns(:nach_member).should eq(NachMember.new(params))
    end
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "creates a new nach_member" do
        params = Factory.attributes_for(:nach_member)
        expect {
          post :create, {:nach_member => params}
        }.to change(NachMember.unscoped, :count).by(1)
        flash[:alert].should  match(/Nach Member successfully created and is pending for approval/)
        response.should be_redirect
      end

      it "assigns a newly created nach_member as @nach_member" do
        params = Factory.attributes_for(:nach_member)
        post :create, {:nach_member => params}
        assigns(:nach_member).should be_a(NachMember)
        assigns(:nach_member).should be_persisted
      end

      it "redirects to the created nach_member" do
        params = Factory.attributes_for(:nach_member)
        post :create, {:nach_member => params}
        response.should redirect_to(NachMember.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved nach_member as @nach_member" do
        params = Factory.attributes_for(:nach_member)
        params[:name] = nil
        expect {
          post :create, {:nach_member => params}
        }.to change(NachMember, :count).by(0)
        assigns(:nach_member).should be_a(NachMember)
        assigns(:nach_member).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:nach_member)
        params[:name] = nil
        post :create, {:nach_member => params}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested nach_member" do
        nach_member = Factory(:nach_member, :name => "CUST01")
        params = nach_member.attributes.slice(*nach_member.class.attribute_names)
        params[:name] = "CUST02"
        put :update, {:id => nach_member.id, :nach_member => params}
        nach_member.reload
        nach_member.name.should == "CUST02"
      end

      it "assigns the requested nach_member as @nach_member" do
        nach_member = Factory(:nach_member, :name => "CUST01")
        params = nach_member.attributes.slice(*nach_member.class.attribute_names)
        params[:name] = "CUST02"
        put :update, {:id => nach_member.to_param, :nach_member => params}
        assigns(:nach_member).should eq(nach_member)
      end

      it "redirects to the nach_member" do
        nach_member = Factory(:nach_member, :name => "CUST01")
        params = nach_member.attributes.slice(*nach_member.class.attribute_names)
        params[:name] = "CUST02"
        put :update, {:id => nach_member.to_param, :nach_member => params}
        response.should redirect_to(nach_member)
      end

      it "should raise error when tried to update at same time by many" do
        nach_member = Factory(:nach_member, :name => "CUST01")
        params = nach_member.attributes.slice(*nach_member.class.attribute_names)
        params[:name] = "CUST02"
        nach_member2 = nach_member
        put :update, {:id => nach_member.id, :nach_member => params}
        nach_member.reload
        nach_member.name.should == "CUST02"
        params[:name] = "CUST03"
        put :update, {:id => nach_member2.id, :nach_member => params}
        nach_member.reload
        nach_member.name.should == "CUST02"
        flash[:alert].should  match(/Someone edited the record the same time you did. Please re-apply your changes to the record/)
      end
    end

    describe "with invalid params" do
      it "assigns the nach_member as @nach_member" do
        nach_member = Factory(:nach_member, :name => "CUST01")
        params = nach_member.attributes.slice(*nach_member.class.attribute_names)
        params[:name] = nil
        put :update, {:id => nach_member.to_param, :nach_member => params}
        assigns(:nach_member).should eq(nach_member)
        nach_member.reload
        params[:name] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        nach_member = Factory(:nach_member)
        params = nach_member.attributes.slice(*nach_member.class.attribute_names)
        params[:name] = nil
        put :update, {:id => nach_member.id, :nach_member => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end
 
  describe "GET audit_logs" do
    it "assigns the requested nach_member as @nach_member" do
      nach_member = Factory(:nach_member)
      get :audit_logs, {:id => nach_member.id, :version_id => 0}
      assigns(:record).should eq(nach_member)
      assigns(:audit).should eq(nach_member.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:record).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end

  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      nach_member1 = Factory(:nach_member, :approval_status => 'A')
      nach_member2 = Factory(:nach_member, :approval_status => 'U', :name => 'Bar Foo', :approved_version => nach_member1.lock_version, :approved_id => nach_member1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      nach_member1.approval_status.should == 'A'
      FtUnapprovedRecord.count.should == 1
      put :approve, {:id => nach_member2.id}
      FtUnapprovedRecord.count.should == 0
      nach_member1.reload
      nach_member1.name.should == 'Bar Foo'
      nach_member1.updated_by.should == "666"
      NachMember.find_by_id(nach_member2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      nach_member = Factory(:nach_member, :name => 'Bar Foo', :approval_status => 'U')
      FtUnapprovedRecord.count.should == 1
      put :approve, {:id => nach_member.id}
      FtUnapprovedRecord.count.should == 0
      nach_member.reload
      nach_member.name.should == 'Bar Foo'
      nach_member.approval_status.should == 'A'
    end
  end
end
