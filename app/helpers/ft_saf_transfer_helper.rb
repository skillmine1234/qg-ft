module FtSafTransferHelper
  def find_ft_saf_transfers(params)
    ft_saf_transfers = FtSafTransfer.order("id desc")
    ft_saf_transfers = ft_saf_transfers.where("LOWER(app_uuid) LIKE ? ", "%#{params[:app_uuid].downcase}%").split(",").collect(&:strip)) if params[:app_uuid].present?
    ft_saf_transfers = ft_saf_transfers.where("LOWER(customer) LIKE ?", "%#{params[:customer_id].downcase}%").split(",").collect(&:strip)) if params[:customer_id].present?
    ft_saf_transfers = ft_saf_transfers.where("LOWER(req_no) LIKE ?", "%#{params[:req_no].downcase}%").split(",").collect(&:strip)) if params[:req_no].present?
    ft_saf_transfers = ft_saf_transfers.where("LOWER(op_name) LIKE ?","%#{params[:op_name].downcase}%") if params[:op_name].present?
    ft_saf_transfers = ft_saf_transfers.where("LOWER(status_code) LIKE ?", "%#{params[:status].downcase}%") if params[:status].present?
    ft_saf_transfers = ft_saf_transfers.where("LOWER(req_transfer_type) LIKE ?", "%#{params[:req_transfer_type].downcase}%") if params[:req_transfer_type].present?
    # ft_saf_transfers = ft_saf_transfers.where("req_timestamp>=? and req_timestamp<=?",Time.zone.parse(params[:from_request_timestamp1]).beginning_of_day,Time.zone.parse(params[:to_request_timestamp1]).end_of_day) if params[:from_req_timestamp1].present? and params[:to_req_timestamp1].present?
    # ft_saf_transfers = ft_saf_transfers.where("rep_timestamp>=? and rep_timestamp<=?",Time.zone.parse(params[:from_reply_timestamp1]).beginning_of_day,Time.zone.parse(params[:to_reply_timestamp1]).end_of_day) if params[:from_reply_timestamp1].present? and params[:to_reply_timestamp1].present?
    ft_saf_transfers = ft_saf_transfers.where("req_timestamp>=? and req_timestamp<=?",Time.zone.parse(params[:from_request_timestamp1]),Time.zone.parse(params[:to_request_timestamp1])) if params[:from_request_timestamp1].present? and params[:to_request_timestamp1].present?
    ft_saf_transfers = ft_saf_transfers.where("rep_timestamp>=? and rep_timestamp<=?",Time.zone.parse(params[:from_reply_timestamp1]),Time.zone.parse(params[:to_reply_timestamp1])) if params[:from_reply_timestamp1].present? and params[:to_reply_timestamp1].present?
    ft_saf_transfers = ft_saf_transfers.where("neft_limit_check=?",params[:neft_limit_check]) if params[:neft_limit_check].present?
    
    ft_saf_transfers
  end
end