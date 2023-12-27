module FundsTransferHelper
  def find_funds_transfers(params)
    fund_transfers = FundsTransfer.order("id desc")
    indivisual_rule = indivisual_rule.where("LOWER(individuals) LIKE ?", "%#{params[:individuals].downcase}%") if params[:individuals].present?

    fund_transfers = fund_transfers.where("LOWER(customer_id) LIKE ?", "%#{params[:customer_id].downcase}%").split(",").collect(&:strip)) if params[:customer_id].present?
    fund_transfers = fund_transfers.where("LOWER(transfer_type) LIKE ?", "%#{params[:transfer_type].downcase}%") if params[:transfer_type].present?
    fund_transfers = fund_transfers.where("status_code=?",params[:status_code]) if params[:status_code].present?
    fund_transfers = fund_transfers.where("req_timestamp>=? and req_timestamp<=?",Time.zone.parse(params[:from_req_timestamp]).beginning_of_day,Time.zone.parse(params[:to_req_timestamp]).end_of_day) if params[:from_req_timestamp].present? and params[:to_req_timestamp].present?
    fund_transfers = fund_transfers.where("rep_timestamp>=? and rep_timestamp<=?",Time.zone.parse(params[:from_rep_timestamp]).beginning_of_day,Time.zone.parse(params[:to_rep_timestamp]).end_of_day) if params[:from_rep_timestamp].present? and params[:to_rep_timestamp].present?
    fund_transfers = fund_transfers.where("transfer_amount>=? and transfer_amount<=?",params[:from_transfer_amount].to_f,params[:to_transfer_amount].to_f) if params[:to_transfer_amount].present? and params[:from_transfer_amount].present?
    fund_transfers = fund_transfers.where("req_no IN (?)",params[:req_no].split(",").collect(&:strip)) if params[:req_no].present?
    fund_transfers = fund_transfers.where("debit_account_no IN (?)",params[:debit_account_no].split(",").collect(&:strip)) if params[:debit_account_no].present?
    fund_transfers = fund_transfers.where("LOWER(bene_account_ifsc) LIKE ?", "%#{params[:bene_account_ifsc].downcase}%").split(",").collect(&:strip)) if params[:bene_account_ifsc].present?
    fund_transfers = fund_transfers.where("LOWER(optn_name) LIKE ?", "%#{params[:optn_name].downcase}%") if params[:optn_name].present?
    fund_transfers = fund_transfers.where("LOWER(ws_saf) LIKE ?", "%#{params[:ws_saf].downcase}%") if params[:ws_saf].present?
    fund_transfers
  end
end
