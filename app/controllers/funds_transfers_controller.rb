class FundsTransfersController < ApplicationController  
  def index
    authorize FundsTransfer
    if request.get?
      # only 'safe/non-personal' parameters are allowed as search parameters in a query string
      @searcher = FundsTransferSearcher.new(params.permit(:page))
    else
      # rest parameters are in post
      @searcher = FundsTransferSearcher.new(search_params)
    end
    @transfers = FundsTransferDecorator.decorate_collection(policy_scope(@searcher).paginate)    
  end
  
  def show
    authorize @funds_transfer = FundsTransfer.find(params[:id]).decorate
  end
  
  def notifications
    authorize ft = FundsTransfer.find(params[:id])
    @steps = ft.notifications
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
        :customer_id)
    end
  end
end