class FtInvoiceDetailsController < ApplicationController
  def index
    authorize FtInvoiceDetail
    @searcher = FtInvoiceDetailSearcher.new(search_params)
    @records = FtInvoiceDetailDecorator.decorate_collection(policy_scope(@searcher).paginate)    
  end
  
  def show
    authorize @ft_invoice_detail = FtInvoiceDetail.find(params[:id]).decorate
  end

  def steps
    authorize ft = FtInvoiceDetail.find(params[:id])
    @steps = FtInvoiceDetailDecorator.decorate_collection(ft.audit_steps)
    render '/audit_steps/index'
  end
  
  private
  
  def search_params
    if request.get?
      params.permit(:page)
    else
      params.require(:ft_invoice_detail_searcher).permit(:page, :status_code, 
        :from_req_timestamp, :to_req_timestamp, 
        :from_rep_timestamp, :to_rep_timestamp, 
        :req_no, :customer_id)
    end
  end
  
  def protected_by_pundit
    true
  end
end