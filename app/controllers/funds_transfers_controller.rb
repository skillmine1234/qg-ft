class FundsTransfersController < ApplicationController  
  before_action :authenticate_user!
  before_action :block_inactive_user!
  include FundsTransferHelper

  def index
    if params[:advanced_search].present?
      funds_transfers = find_funds_transfers(params).order("id DESC")
    else
      funds_transfers = FundsTransfer.order("id desc")
    end
    @funds_transfers = funds_transfers.paginate(:per_page => 10, :page => params[:page]) rescue []
  end
  
  def show
    authorize @funds_transfer = FundsTransfer.find(params[:id]).decorate
  end

  def steps
    authorize ft = FundsTransfer.find(params[:id])
    @steps = FundsTransferDecorator.decorate_collection(ft.audit_steps)
    render '/audit_steps/index'
  end
  
  private
  
  def search_params
    if request.get?
      params.permit(:page)
    else
      params.require(:funds_transfer_searcher).permit(:page, :transfer_type, :status_code, 
        :from_req_timestamp, :to_req_timestamp, 
        :from_rep_timestamp, :to_rep_timestamp, 
        :from_transfer_amount, :to_transfer_amount, 
        :req_no, :debit_account_no, :bene_account_ifsc, 
        :customer_id, :optn_name, :ws_saf)
    end
  end
  
  def protected_by_pundit
    true
  end
end