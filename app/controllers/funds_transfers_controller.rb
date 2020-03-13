class FundsTransfersController < ApplicationController  
  def index
    authorize FundsTransfer
    if request.get?
      # only 'safe/non-personal' parameters are allowed as search parameters in a query string
      @advance_search = false
      @searcher = FundsTransferSearcher.new
    else
      # rest parameters are in post\
      @advance_search = true
      @searcher = FundsTransferSearcher.new(search_params)
    end
    @records = FundsTransferDecorator.decorate_collection(policy_scope(@searcher).paginate) 
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