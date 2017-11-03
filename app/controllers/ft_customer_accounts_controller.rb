class FtCustomerAccountsController < ApplicationController
  authorize_resource
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  include FtCustomerAccountsHelper
  
  def new
    @ft_customer_account = FtCustomerAccount.new
  end

  def create
    @ft_customer_account = FtCustomerAccount.new(params[:ft_customer_account])
    if !@ft_customer_account.valid?
      render "new"
    else
      @ft_customer_account.created_by = current_user.id
      @ft_customer_account.save!
      flash[:alert] = "Customer Account successfully #{@ft_customer_account.approved_id.nil? ? 'created' : 'updated'} and is pending for approval"
      redirect_to @ft_customer_account
    end
  end 

  def edit
    ft_customer_account = FtCustomerAccount.unscoped.find_by_id(params[:id])
    if ft_customer_account.approval_status == 'A' && ft_customer_account.unapproved_record.nil?
      params = (ft_customer_account.attributes).merge({:approved_id => ft_customer_account.id,:approved_version => ft_customer_account.lock_version})
      ft_customer_account = FtCustomerAccount.new(params)
    end
    @ft_customer_account = ft_customer_account   
  end

  def update
    @ft_customer_account = FtCustomerAccount.unscoped.find_by_id(params[:id])
    @ft_customer_account.attributes = params[:ft_customer_account]
    if !@ft_customer_account.valid?
      render "edit"
    else
      @ft_customer_account.updated_by = current_user.id
      @ft_customer_account.save!
      flash[:alert] = 'Customer Account successfully modified and is pending for approval'
      redirect_to @ft_customer_account
    end
    rescue ActiveRecord::StaleObjectError
      @ft_customer_account.reload
      flash[:alert] = 'Someone edited the Customer Account the same time you did. Please re-apply your changes to the Customer.'
      render "edit"
  end 

  def show
    @ft_customer_account = FtCustomerAccount.unscoped.find_by_id(params[:id])
  end

  def index
    if params[:advanced_search].present?
      ft_customer_accounts = find_ft_customer_accounts(params).order("id desc")
    else
      ft_customer_accounts = (params[:approval_status].present? and params[:approval_status] == 'U') ? FtCustomerAccount.unscoped.where("approval_status =?",'U').order("id desc") : FtCustomerAccount.order("id desc")
    end
    @ft_customer_accounts_count = ft_customer_accounts.count
    @ft_customer_accounts = ft_customer_accounts.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def audit_logs
    @ft_customer_account = FtCustomerAccount.unscoped.find(params[:id]) rescue nil
    @audit = @ft_customer_account.audits[params[:version_id].to_i] rescue nil
  end
  
  def approve
    @ft_customer_account = FtCustomerAccount.unscoped.find(params[:id]) rescue nil
    FtCustomerAccount.transaction do
      approval = @ft_customer_account.approve
      if @ft_customer_account.save and approval.empty?
        flash[:alert] = "Customer Account record was approved successfully"
      else
        msg = approval.empty? ? @ft_customer_account.errors.full_messages : @ft_customer_account.errors.full_messages << approval
        flash[:alert] = msg
        raise ActiveRecord::Rollback
      end
    end
    redirect_to @ft_customer_account
  end
  
  def destroy
    ft_customer_account = FtCustomerAccount.unscoped.find_by_id(params[:id])
    if ft_customer_account.approval_status == 'U' and (current_user == ft_customer_account.created_user or (can? :approve, ft_customer_account))
      ft_customer_account = ft_customer_account.destroy
      flash[:alert] = "Funds Transfer Customer Account record has been deleted!"
      redirect_to ft_customer_accounts_path(:approval_status => 'U')
    else
      flash[:alert] = "You cannot delete this record!"
      redirect_to ft_customer_accounts_path(:approval_status => 'U')
    end
  end

  private

  def ft_customer_account_params
    params.require(:ft_customer_account).permit(:customer_id, :account_no, :is_enabled, 
                                                :lock_version, :approval_status,
                                                :last_action, :approved_version, :approved_id, :created_by, :updated_by)
  end
end
