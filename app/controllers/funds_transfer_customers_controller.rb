class FundsTransferCustomersController < ApplicationController
  authorize_resource
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  include FundsTransferCustomersHelper
  
  def new
    @funds_transfer_customer = FundsTransferCustomer.new
  end

  def create
    @funds_transfer_customer = FundsTransferCustomer.new(params[:funds_transfer_customer])
    if !@funds_transfer_customer.valid?
      render "new"
    else
      @funds_transfer_customer.created_by = current_user.id
      @funds_transfer_customer.save!
      flash[:alert] = "Customer successfully #{@funds_transfer_customer.approved_id.nil? ? 'created' : 'updated'} and is pending for approval"
      redirect_to @funds_transfer_customer
    end
  end 

  def edit
    funds_transfer_customer = FundsTransferCustomer.unscoped.find_by_id(params[:id])
    if funds_transfer_customer.approval_status == 'A' && funds_transfer_customer.unapproved_record.nil?
      params = (funds_transfer_customer.attributes).merge({:approved_id => funds_transfer_customer.id,:approved_version => funds_transfer_customer.lock_version})
      funds_transfer_customer = FundsTransferCustomer.new(params)
    end
    @funds_transfer_customer = funds_transfer_customer   
  end

  def update
    @funds_transfer_customer = FundsTransferCustomer.unscoped.find_by_id(params[:id])
    @funds_transfer_customer.attributes = params[:funds_transfer_customer]
    if !@funds_transfer_customer.valid?
      render "edit"
    else
      @funds_transfer_customer.updated_by = current_user.id
      @funds_transfer_customer.save!
      flash[:alert] = 'Customer successfully modified and is pending for approval'
      redirect_to @funds_transfer_customer
    end
    rescue ActiveRecord::StaleObjectError
      @funds_transfer_customer.reload
      flash[:alert] = 'Someone edited the Customer the same time you did. Please re-apply your changes to the Customer.'
      render "edit"
  end 

  def show
    @funds_transfer_customer = FundsTransferCustomer.unscoped.find_by_id(params[:id])
  end

  def index
    if params[:advanced_search].present?
      funds_transfer_customers = find_funds_transfer_customers(params).order("id desc")
    else
      funds_transfer_customers = (params[:approval_status].present? and params[:approval_status] == 'U') ? FundsTransferCustomer.unscoped.where("approval_status =?",'U').order("id desc") : FundsTransferCustomer.order("id desc")
    end
    @funds_transfer_customers_count = funds_transfer_customers.count
    @funds_transfer_customers = funds_transfer_customers.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def audit_logs
    @funds_transfer_customer = FundsTransferCustomer.unscoped.find(params[:id]) rescue nil
    @audit = @funds_transfer_customer.audits[params[:version_id].to_i] rescue nil
  end
  
  def approve
    @funds_transfer_customer = FundsTransferCustomer.unscoped.find(params[:id]) rescue nil
    FundsTransferCustomer.transaction do
      approval = @funds_transfer_customer.approve
      if @funds_transfer_customer.save and approval.empty?
        flash[:alert] = "Customer record was approved successfully"
      else
        msg = approval.empty? ? @funds_transfer_customer.errors.full_messages : @funds_transfer_customer.errors.full_messages << approval
        flash[:alert] = msg
        raise ActiveRecord::Rollback
      end
    end
    redirect_to @funds_transfer_customer
  end
  
  def destroy
    funds_transfer_customer = FundsTransferCustomer.unscoped.find_by_id(params[:id])
    if funds_transfer_customer.approval_status == 'U' and (current_user == funds_transfer_customer.created_user or (can? :approve, funds_transfer_customer))
      funds_transfer_customer = funds_transfer_customer.destroy
      flash[:alert] = "Funds Transfer Customer record has been deleted!"
      redirect_to funds_transfer_customers_path(:approval_status => 'U')
    else
      flash[:alert] = "You cannot delete this record!"
      redirect_to funds_transfer_customers_path(:approval_status => 'U')
    end
  end

  def resend_notification
    @funds_transfer_customer = FundsTransferCustomer.find(params[:id]) rescue nil
    flash[:alert] = @funds_transfer_customer.resend_setup
    redirect_to @funds_transfer_customer
  end

  private

  def funds_transfer_customer_params
    params.require(:funds_transfer_customer).permit(:app_id, :name, :low_balance_alert_at, :identity_user_id, :allow_neft, :allow_imps, 
                                                    :enabled, :customer_id, :lock_version, :approval_status, :allow_rtgs, :is_retail,
                                                    :last_action, :approved_version, :approved_id, :created_by, :updated_by, :needs_purpose_code,
                                                    :reply_with_bene_name, :allow_all_accounts, :is_filetoapi_allowed, :allow_apbs, :apbs_user_no, 
                                                    :apbs_user_name, :notify_on_status_change, :notify_app_code, :notification_sent_at, :force_saf,
                                                    {allowed_relns: []}, :use_std_relns, :bene_backend)
  end
end
