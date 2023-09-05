class FundsTransferSearcher < Searcher
  attr_searchable :req_no, :debit_account_no, :from_transfer_amount, :to_transfer_amount, :from_req_timestamp, :to_req_timestamp, 
                  :from_rep_timestamp, :to_rep_timestamp, :transfer_type, :bene_account_ifsc, :status_code, :customer_id, :optn_name, :ws_saf
  
  as_enum :status_code, [:FAILED, :RETURNED_FROM_BENEFICIARY, :NEW, :SENT_TO_BENEFICIARY, :SCHEDULED_FOR_NEXT_WORKDAY, :IN_PROCESS, :COMPLETED, :ONHOLD], map: :string, source: :status_code
  as_enum :transfer_type, [:NEFT, :IMPS, :RTGS, :FT, :APBS], map: :string, source: :transfer_type
  as_enum :optn_name, [:startTransfer, :transfer], map: :string, source: :optn_name
  as_enum :ws_saf, [:Y, :N], map: :string, source: :ws_saf

  private

  def find
    reln = FundsTransfer.order("id desc")
    reln = reln.where("transfer_amount>=? and transfer_amount<=?",from_transfer_amount,to_transfer_amount) if from_transfer_amount.present? and to_transfer_amount.present?
    reln = reln.where("req_timestamp>=? and req_timestamp<=?",Time.zone.parse(from_req_timestamp),Time.zone.parse(to_req_timestamp)) if from_req_timestamp.present? and to_req_timestamp.present?
    reln = reln.where("rep_timestamp>=? and rep_timestamp<=?",Time.zone.parse(from_rep_timestamp),Time.zone.parse(to_rep_timestamp)) if from_rep_timestamp.present? and to_rep_timestamp.present?
    reln = reln.where("was_saf=? or was_saf is NULL",ws_saf) if ws_saf.present? and ws_saf == 'N'
    reln = reln.where("was_saf=?",ws_saf) if ws_saf.present? and ws_saf == 'Y'
    reln = reln.where("op_name=? or op_name is NULL",optn_name) if optn_name.present? and optn_name == 'transfer'
    reln = reln.where("op_name=?",optn_name) if optn_name.present? and optn_name == 'startTransfer'
    reln
  end
end