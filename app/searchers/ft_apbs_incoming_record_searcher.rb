class FtApbsIncomingRecordSearcher
  attr_accessor :page, :apbs_trans_code, :dest_bank_iin, :sponser_bank_iin, :bene_acct_name, :file_name, :status, :overrided_flag

  PER_PAGE = 10

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def paginate
    find.paginate(per_page: PER_PAGE, page: page)
  end

  private
  def persisted?
    false
  end

  def find
    reln = FtApbsIncomingRecord.joins(:incoming_file_record).where("ft_apbs_incoming_records.file_name=? and incoming_file_records.status=?", file_name, status).order("ft_apbs_incoming_records.id desc")
    reln = reln.where("incoming_file_records.overrides is not null") if overrided_flag.present? and overrided_flag == "true"
    reln = reln.where("incoming_file_records.overrides is null") if overrided_flag.present? and overrided_flag == "false"
    reln = reln.where("ft_apbs_incoming_records.apbs_trans_code=?",apbs_trans_code) if apbs_trans_code.present?
    reln = reln.where("ft_apbs_incoming_records.dest_bank_iin=?",dest_bank_iin) if dest_bank_iin.present?
    reln = reln.where("ft_apbs_incoming_records.sponser_bank_iin=?",sponser_bank_iin) if sponser_bank_iin.present?
    reln = reln.where("ft_apbs_incoming_records.bene_acct_name=?",bene_acct_name) if bene_acct_name.present?
    reln
  end
end