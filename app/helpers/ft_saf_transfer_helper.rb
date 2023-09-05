module FtSafTransferHelper
  def find_ft_saf_transfers(params)
    ft_saf_transfers = FtSafTransfer.order("id desc")
    ft_saf_transfers = ft_saf_transfers.where("app_uuid IN (?) ", params[:app_uuid].split(",").collect(&:strip)) if params[:app_uuid].present?
    ft_saf_transfers = ft_saf_transfers.where("customer_id IN (?) ", params[:customer_id].split(",").collect(&:strip)) if params[:customer_id].present?
    ft_saf_transfers = ft_saf_transfers.where("req_no IN (?)", params[:req_no].split(",").collect(&:strip)) if params[:req_no].present?
    ft_saf_transfers = ft_saf_transfers.where("op_name=?",params[:op_name]) if params[:op_name].present?
    ft_saf_transfers = ft_saf_transfers.where("status_code=?",params[:status]) if params[:status].present?
    ft_saf_transfers = ft_saf_transfers.where("req_transfer_type=?",params[:req_transfer_type]) if params[:req_transfer_type].present?
    # ft_saf_transfers = ft_saf_transfers.where("req_timestamp>=? and req_timestamp<=?",Time.zone.parse(params[:from_request_timestamp1]).beginning_of_day,Time.zone.parse(params[:to_request_timestamp1]).end_of_day) if params[:from_req_timestamp1].present? and params[:to_req_timestamp1].present?
    # ft_saf_transfers = ft_saf_transfers.where("rep_timestamp>=? and rep_timestamp<=?",Time.zone.parse(params[:from_reply_timestamp1]).beginning_of_day,Time.zone.parse(params[:to_reply_timestamp1]).end_of_day) if params[:from_reply_timestamp1].present? and params[:to_reply_timestamp1].present?
    ft_saf_transfers = ft_saf_transfers.where("req_timestamp>=? and req_timestamp<=?",Time.zone.parse(params[:from_request_timestamp1]),Time.zone.parse(params[:to_request_timestamp1])) if params[:from_request_timestamp1].present? and params[:to_request_timestamp1].present?
    ft_saf_transfers = ft_saf_transfers.where("rep_timestamp>=? and rep_timestamp<=?",Time.zone.parse(params[:from_reply_timestamp1]),Time.zone.parse(params[:to_reply_timestamp1])) if params[:from_reply_timestamp1].present? and params[:to_reply_timestamp1].present?
    ft_saf_transfers = ft_saf_transfers.where("neft_limit_check=?",params[:neft_limit_check]) if params[:neft_limit_check].present?
    
    ft_saf_transfers
  end
end