class FtSafTransferSearcher
  include ActiveModel::Validations
  attr_accessor :page, :app_uuid, :customer_id, :req_no, :op_name, :status, :req_transfer_type, :from_request_timestamp, :to_request_timestamp, :from_reply_timestamp, :to_reply_timestamp
  PER_PAGE = 10
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def paginate
    if valid? 
      find.paginate(per_page: PER_PAGE, page: page)
    else
      FtSafTransfer.none.paginate(per_page: PER_PAGE, page: page)
    end
  end

  private  
  def persisted?
    false
  end

  def find
    reln = FtSafTransfer.order("id desc")
    reln = reln.where("app_uuid IN (?) ", app_uuid.split(",").collect(&:strip)) if app_uuid.present?
    reln = reln.where("customer_id IN (?) ", customer_id.split(",").collect(&:strip)) if customer_id.present?
    reln = reln.where("req_no IN (?)", req_no.split(",").collect(&:strip)) if req_no.present?
    reln = reln.where("op_name=?",op_name) if op_name.present?
    reln = reln.where("status_code=?",status) if status.present?
    reln = reln.where("req_transfer_type=?",req_transfer_type) if req_transfer_type.present?
    reln = reln.where("req_timestamp>=? and req_timestamp<=?",Time.zone.parse(from_request_timestamp),Time.zone.parse(to_request_timestamp)) if from_request_timestamp.present? and to_request_timestamp.present?
    reln = reln.where("rep_timestamp>=? and rep_timestamp<=?",Time.zone.parse(from_reply_timestamp),Time.zone.parse(to_reply_timestamp)) if from_reply_timestamp.present? and to_reply_timestamp.present?
    reln
  end
end