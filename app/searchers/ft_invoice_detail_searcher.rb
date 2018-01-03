class FtInvoiceDetailSearcher < Searcher
  attr_searchable :funds_transfer_id, :req_no, :customer_id, :status_code, {req_timestamp: :range}, {rep_timestamp: :range}
  as_enum :status_code, [:FAILED, :RETURNED_FROM_BENEFICIARY, :NEW, :SENT_TO_BENEFICIARY, :SCHEDULED_FOR_NEXT_WORKDAY, :IN_PROCESS, :COMPLETED, :ONHOLD, :'TIMED OUT'], map: :string, source: :status_code

  private 
  
  def find
    reln = FtInvoiceDetail.failed_invoices.order('id desc')
    reln
  end
end