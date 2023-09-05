class FtSafTransfersController < ApplicationController
  authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  include FtSafTransferHelper

  def index
    if params[:advanced_search].present?
      ft_saf_transfers = find_ft_saf_transfers(params).order("id DESC")
    else
      ft_saf_transfers = FtSafTransfer.order("id desc")
    end
    @ft_saf_transfers = ft_saf_transfers.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def show
    @ft_saf_transfer = FtSafTransfer.find(params[:id])
  end
  
  def destroy
    ft_saf_transfer = FtSafTransfer.find(params[:id])
    if ft_saf_transfer.destroy
      flash[:alert] = "SAF Transfer record has been deleted!"
    else
      flash[:alert] = "SAF Transfer record cannot be deleted!"
    end
    redirect_to ft_saf_transfers_path
  end

  private

  def search_params
    params.permit(:page, :app_uuid, :customer_id, :req_no, :op_name, :status, :req_transfer_type, :from_request_timestamp, :to_request_timestamp, :from_reply_timestamp, :to_reply_timestamp)
  end
end
