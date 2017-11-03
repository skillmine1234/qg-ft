class FtSafTransfersController < ApplicationController
  authorize_resource
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json
  include ApplicationHelper

  def index
    if request.get?
      @searcher = FtSafTransferSearcher.new(params.permit(:page))
    else
      @searcher = FtSafTransferSearcher.new(search_params)
    end
    @records = @searcher.paginate
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
    params.permit(:page, :app_uuid, :customer_id, :req_no, :op_name, :req_transfer_type, :from_request_timestamp, :to_request_timestamp, :from_reply_timestamp, :to_reply_timestamp)
  end
end
