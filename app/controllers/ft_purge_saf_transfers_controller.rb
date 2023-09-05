class FtPurgeSafTransfersController < ApplicationController
  #authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json  
  include ApplicationHelper
  
  def new
    @ft_purge_saf_transfer = FtPurgeSafTransfer.new
  end

  def create
    @ft_purge_saf_transfer = FtPurgeSafTransfer.new(params[:ft_purge_saf_transfer])
    if !@ft_purge_saf_transfer.valid?
      render "new"
    else
      @ft_purge_saf_transfer.created_by = current_user.id
      @ft_purge_saf_transfer.save!
      flash[:alert] = "Record successfully created and is pending for approval"
      redirect_to @ft_purge_saf_transfer
    end
  end

  def show
    @ft_purge_saf_transfer = FtPurgeSafTransfer.unscoped.find_by_id(params[:id])
    @rows_count = @ft_purge_saf_transfer.get_txns_count
  rescue ::Fault::ProcedureFault, OCIError => e
    @error = "Error: #{e.message}" 
  end
  
  def index
    if params[:advanced_search].present?
      @records = FtPurgeSafTransfer.order("id desc").paginate(:per_page => 10, :page => params[:page])
    else
      @records = (params[:approval_status].present? and params[:approval_status] == 'U') ? FtPurgeSafTransfer.unscoped.where("approval_status =?",'U').order("id desc").paginate(:per_page => 10, :page => params[:page]) : FtPurgeSafTransfer.order("id desc").paginate(:per_page => 10, :page => params[:page])
    end
  end
  
  def approve
    @ft_purge_saf_transfer = FtPurgeSafTransfer.unscoped.find(params[:id]) rescue nil
    FtPurgeSafTransfer.transaction do
      approval = @ft_purge_saf_transfer.approve
      if @ft_purge_saf_transfer.save and approval.empty?
        flash[:alert] = "Record was approved successfully"
      else
        msg = approval.empty? ? @ft_purge_saf_transfer.errors.full_messages : @ft_purge_saf_transfer.errors.full_messages << approval
        flash[:alert] = msg
        raise ActiveRecord::Rollback
      end
    end
  rescue OCIError => e
    flash[:alert] = "#{e.message}"
  ensure
    redirect_to @ft_purge_saf_transfer
  end

  private

  def ft_purge_saf_transfer_params
    params.require(:ft_purge_saf_transfer).permit(:reference_no, :from_req_timestamp, :to_req_timestamp, :customer_id, :op_name, :req_transfer_type, 
                                                  :created_at, :updated_at, :created_by, :updated_by, :lock_version, :approved_id, :approved_version,
                                                  :status_code)
  end
end