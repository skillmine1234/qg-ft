class FundsTransferCustomersController < ApplicationController
  #authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
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
      @funds_transfer_customer.rtgs_confirmation_enabled = "Y" if @funds_transfer_customer.n10_notification_enabled == "Y"
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
      funds_transfer_customers = find_funds_transfer_customers(params).order("id DESC")
    else
      funds_transfer_customers = (params[:approval_status].present? and params[:approval_status] == 'U') ? FundsTransferCustomer.unscoped.where("approval_status =?",'U').order("id desc") : FundsTransferCustomer.order("id desc")
    end
    @funds_transfer_customers = funds_transfer_customers.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def validate_app_id_ft_customer
    if params[:app_id1].present?
      @funds_transfer_customer = FundsTransferCustomer.where(app_id: params[:app_id1])
    end
  end

  def validate_customer_id_ft_customer
    if params[:customer_id1].present?
      @funds_transfer_customer = FundsTransferCustomer.where(customer_id: params[:customer_id1]).first
      if @funds_transfer_customer.present?
        render json: {}, status: 400
      else
        render json: {}, status: 200
      end
    end
    if @funds_transfer_customer.nil?
      @funds_transfer_customer = FundsTransferCustomer.new
    end
  end

  def display_associated_customer_id
    @funds_transfer_customer = FundsTransferCustomer.where(app_id: params[:app_id2])
  end

  def check_duplicate_account_no
    @ft_customer = FundsTransferCustomer.find_by(app_id: params[:app_id4],customer_id: params[:ft_customer_id2])
    if @ft_customer.present?
      @ft_account = FtCustomerAccount.where(account_no: params[:account_no1],customer_id: @ft_customer.customer_id)
      @ft_account_all = FtCustomerAccount.where(account_no: params[:account_no1])
      @ft_account_unapproved = FtCustomerAccount.unscoped.where(account_no: params[:account_no1])
      if @ft_account.present? || @ft_account_all.present? || @ft_account_unapproved.present?
        puts "Account_No Exist!!"
      else
        puts "Account_No not Exist!!"
      end
    end
  end

  def create_clone_accounts
    if params[:fund_transfer].present?
      ft_customer = FundsTransferCustomer.find_by(customer_id: params[:ft_customer_id])
      params[:fund_transfer][:account_no].each do |account_no|
        ft_customer_account = FtCustomerAccount.find_by(account_no: account_no,customer_id: params[:ft_customer_id])
        if !ft_customer_account.present?
          ft_account = FtCustomerAccount.new(account_no: account_no,customer_id: ft_customer.customer_id,is_enabled: "Y",created_by: current_user.id).save!
        end
      end
      flash[:alert] = "Account Replicated successfully"
      redirect_to "/funds_transfer_customers"
    end
  end

  def validate_app_id_child_ft_customer
    if params[:child_app_id1].present?
      @funds_transfer_customer = FundsTransferCustomer.where(app_id: params[:child_app_id1])
      @funds_transfer_customer1 = FundsTransferCustomer.where(app_id: params[:child_app_id1],category: "Master")
    end
  end

  def check_duplicate_customer_id
    @ft_customers = FundsTransferCustomer.where(app_id: params[:app_id4],customer_id: params[:ft_customer_id2])
    if @ft_customers.present?
      puts "FT Customer already associated with this Customer ID!"
      # render json: {}, status: 400
    else
      puts "FT Customer not associated with this Customer ID!"
      # render json: {}, status: 200
    end
  end

  def validate_app_id_customer_id_ft_customer
    @funds_transfer_customer = FundsTransferCustomer.where(app_id: params[:app_id],category: "Master")
    if @funds_transfer_customer.present?
      render json: {}, status: 400
    else
      render json: {}, status: 200
    end
  end

  def create_child_ft_customers
    if params[:fund_transfer].present?
      ft_cust1 = FundsTransferCustomer.find_by(app_id: params[:ft_app_id],category: ["Master"])
      puts "--------FT Customer Present?----->#{ft_cust1.present?}----------"
      puts "--------App ID Value----->#{params[:ft_app_id]}----------"
      customer_id_params = params[:fund_transfer][:customer_id].reject { |c| c.empty? }
      if customer_id_params.present? && ft_cust1.present?
        customer_id_params.each do |customer_id|
          puts "--------Inside Each FT Customer Present?----->#{ft_cust1.present?}----------"
          puts "--------Inside Each App ID Value----->#{ft_cust1.app_id}----------" if ft_cust1.present?
          ft_customer_child = FundsTransferCustomer.find_by(app_id: ft_cust1.app_id,customer_id: customer_id)
          if !ft_customer_child.present? && ft_cust1.present?
            ft_cust = FundsTransferCustomer.new(app_id: ft_cust1.app_id,
                                                customer_id: customer_id,
                                                name: ft_cust1.name,
                                                low_balance_alert_at:  ft_cust1.low_balance_alert_at,
                                                identity_user_id: ft_cust1.identity_user_id,
                                                allow_neft: ft_cust1.allow_neft,
                                                allow_imps: ft_cust1.allow_imps,
                                                allow_rtgs: ft_cust1.allow_rtgs,
                                                enabled: ft_cust1.enabled,
                                                is_retail: ft_cust1.is_retail,
                                                created_by: current_user.id,
                                                needs_purpose_code: ft_cust1.needs_purpose_code,
                                                reply_with_bene_name: ft_cust1.reply_with_bene_name,
                                                allow_all_accounts: ft_cust1.allow_all_accounts,
                                                notify_app_code: ft_cust1.notify_app_code,
                                                notify_on_status_change: ft_cust1.notify_on_status_change,
                                                is_filetoapi_allowed: ft_cust1.is_filetoapi_allowed,
                                                allow_apbs: ft_cust1.allow_apbs,
                                                apbs_user_no: ft_cust1.apbs_user_no,
                                                apbs_user_name: ft_cust1.apbs_user_name,
                                                notification_sent_at: ft_cust1.notification_sent_at,
                                                force_saf: ft_cust1.force_saf,
                                                allowed_relns: ft_cust1.allowed_relns,
                                                bene_backend: ft_cust1.bene_backend,
                                                allow_upi: ft_cust1.allow_upi,
                                                beneficiary_sms_allowed: ft_cust1.beneficiary_sms_allowed,
                                                beneficiary_email_allowed: ft_cust1.beneficiary_email_allowed,
                                                is_bulk: ft_cust1.is_bulk,
                                                btid: ft_cust1.btid,
                                                customer_code: ft_cust1.customer_code,
                                                working_day_limit: ft_cust1.working_day_limit,
                                                non_working_day_limit: ft_cust1.non_working_day_limit,
                                                neft_limit_check: ft_cust1.neft_limit_check,
                                                n10_notification_enabled: ft_cust1.n10_notification_enabled,
                                                rtgs_confirmation_enabled: ft_cust1.rtgs_confirmation_enabled,
                                                intelligent_routing_check: ft_cust1.intelligent_routing_check,
                                                neft_limit_check: ft_cust1.neft_limit_check,
                                                working_day_limit: ft_cust1.working_day_limit,
                                                non_working_day_limit: ft_cust1.non_working_day_limit,
                                                action_limit_breach: ft_cust1.action_limit_breach,
                                                bulk_backend: ft_cust1.bulk_backend,
                                                category: "Child").save!
          end
        end
        flash[:alert] = "Child Setup Created successfully"
        redirect_to "/funds_transfer_customers"
      else
        message = "Child Setup can't be Created since Customer ID's are blank!" if customer_id_params.blank? && ft_cust1.present?
        message = "Child Setup can't be Created since FT Customer not linked with Master!" if customer_id_params.present? && ft_cust1.blank?
        message = "Child Setup can't be Created since Customer ID's are blank or FT Customer not linked with Master!" if customer_id_params.blank? && ft_cust1.blank?
        flash[:alert] = "#{message}"
        redirect_to "/funds_transfer_customers"
      end
    end
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

  def deactivate_user
    @funds_transfer_customer = FundsTransferCustomer.where("app_id IN (?) OR customer_id IN (?)",params[:app_id],params[:customer_id])
  end

  def deactivation_customer_final_list
    ft_dis_list = FtCustomerDisableList.new(app_id: params[:app_ids],
                                            customer_id: params[:customer_ids],
                                            created_by: params[:current_user])
    ft_dis_list.save

    flash[:alert] = "Request sent for approval"
    redirect_to '/funds_transfer_customers'
  end

  private

  def funds_transfer_customer_params
    params.require(:funds_transfer_customer).permit(:app_id, :name, :low_balance_alert_at, :identity_user_id, :allow_neft, :allow_imps, 
                                                    :enabled, :customer_id, :lock_version, :approval_status, :allow_rtgs, :is_retail,
                                                    :last_action, :approved_version, :approved_id, :created_by, :updated_by, :needs_purpose_code,
                                                    :reply_with_bene_name, :allow_all_accounts, :is_filetoapi_allowed, :allow_apbs, :apbs_user_no, 
                                                    :apbs_user_name, :notify_on_status_change, :notify_app_code, :notification_sent_at, :force_saf,
                                                    {allowed_relns: []},:use_std_relns, :bene_backend,:beneficiary_sms_allowed,:beneficiary_email_allowed,
                                                    :is_bulk,:btid,:customer_code,:working_day_limit,:non_working_day_limit,:neft_limit_check,
                                                    :n10_notification_enabled,:rtgs_confirmation_enabled,:category,
                                                    :intelligent_routing_check,:action_limit_breach,:notify_downtime,:bulk_backend)
  end
end
