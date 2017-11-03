class FtPurposeCode < ActiveRecord::Base
  include Approval
  include FtApproval

  TRANSFER_TYPES = [['IMPS','IMPS'],['NEFT','NEFT'],['RTGS','RTGS']]

  serialize :allowed_transfer_types, ArrayAsCsv
  
  store :setting1, accessors: [:setting1_name, :setting1_type, :setting1_value], coder: JSON
  store :setting2, accessors: [:setting2_name, :setting2_type, :setting2_value], coder: JSON
  store :setting3, accessors: [:setting3_name, :setting3_type, :setting3_value], coder: JSON
  store :setting4, accessors: [:setting4_name, :setting4_type, :setting4_value], coder: JSON
  store :setting5, accessors: [:setting5_name, :setting5_type, :setting5_value], coder: JSON

  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'
  
  before_validation :set_transfer_type, unless: "self.frozen?"

  validates_presence_of :code, :description, :is_enabled, :allowed_transfer_types
  validates :code, format: {with: /\A[a-z|A-Z|0-9]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9]}'}, length: {minimum: 2, maximum: 6}
  validates :description, format: {with: /\A[a-z|A-Z|0-9|\s|\.|\-]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9|\s|\.|\-]}'}

  validates_uniqueness_of :code, :scope => :approval_status
  
  validate :check_allowed_transfer_types
  validate :check_frozen, if: "is_frozen=='Y' && approval_status=='U'"
  validate :value_for_reg_bene_for_apbs, if: "allowed_transfer_types.include?('APBS')"
  
  before_save :set_settings_cnt, unless: "self.frozen?"

  private
  
  def set_transfer_type
    self.allowed_transfer_types = ['APBS'] if (self.approved_record.present? && self.approved_record.allowed_transfer_types == ['APBS'] && allowed_transfer_types.blank?)
  end

  def value_for_reg_bene_for_apbs
    errors.add(:allow_only_registered_bene, "Allow Only Registered Bene cannot be enabled when APBS is allowed") if allow_only_registered_bene == 'Y'
  end

  def check_allowed_transfer_types
    errors.add(:allowed_transfer_types, "Either APBS or one or more of [IMPS, NEFT, RTGS] can be selected") if allowed_transfer_types.include?('APBS') && (allowed_transfer_types.include?('IMPS') || allowed_transfer_types.include?('RTGS') || allowed_transfer_types.include?('NEFT'))
  end

  def check_frozen
    self.changes.each do |c|
      if ['code', 'allow_only_registered_bene', 'allowed_transfer_types'].include?(c[0])
        errors.add(c[0].to_sym, 'Not allowed to be edited') if c[1][1] != self.approved_record.send(c[0].to_sym)
      end
    end
  end

  def set_settings_cnt
    self.settings_cnt = 0
    self.settings_cnt += 1 unless setting1_name.blank?
    self.settings_cnt += 1 unless setting2_name.blank?
    self.settings_cnt += 1 unless setting3_name.blank?
    self.settings_cnt += 1 unless setting4_name.blank?
    self.settings_cnt += 1 unless setting5_name.blank?
  end
end