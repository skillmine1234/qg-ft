module FundsTransferHelper
  def find_funds_transfers(params)
    fund_transfers = FundsTransfer.order("id desc")
    fund_transfers = fund_transfers.where("customer_id IN (?)",params[:customer_id].split(",").collect(&:strip)) if params[:customer_id].present?
    fund_transfers = fund_transfers.where("transfer_type=?",params[:transfer_type]) if params[:transfer_type].present?
    fund_transfers = fund_transfers.where("status_code=?",params[:status_code]) if params[:status_code].present?
    fund_transfers = fund_transfers.where("req_timestamp>=? and req_timestamp<=?",Time.zone.parse(params[:from_req_timestamp]).beginning_of_day,Time.zone.parse(params[:to_req_timestamp]).end_of_day) if params[:from_req_timestamp].present? and params[:to_req_timestamp].present?
    fund_transfers = fund_transfers.where("rep_timestamp>=? and rep_timestamp<=?",Time.zone.parse(params[:from_rep_timestamp]).beginning_of_day,Time.zone.parse(params[:to_rep_timestamp]).end_of_day) if params[:from_rep_timestamp].present? and params[:to_rep_timestamp].present?
    fund_transfers = fund_transfers.where("transfer_amount>=? and transfer_amount<=?",params[:from_transfer_amount].to_f,params[:to_transfer_amount].to_f) if params[:to_transfer_amount].present? and params[:from_transfer_amount].present?
    fund_transfers = fund_transfers.where("req_no IN (?)",params[:req_no].split(",").collect(&:strip)) if params[:req_no].present?
    fund_transfers = fund_transfers.where("debit_account_no IN (?)",params[:debit_account_no].split(",").collect(&:strip)) if params[:debit_account_no].present?
    fund_transfers = fund_transfers.where("bene_account_ifsc IN (?)",params[:bene_account_ifsc].split(",").collect(&:strip)) if params[:bene_account_ifsc].present?
    fund_transfers = fund_transfers.where("optn_name=?",params[:optn_name]) if params[:optn_name].present?
    fund_transfers = fund_transfers.where("ws_saf=?",params[:ws_saf]) if params[:ws_saf].present?
    fund_transfers
  end
end
