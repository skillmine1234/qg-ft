class NachMember < ActiveRecord::Base
  include Approval
  include FtApproval

  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'

  validates_presence_of :iin, :name, :is_enabled
  validates_uniqueness_of :iin#, scope: [:approval_status]
  validates :iin, format: {with: /\A[A-Z|a-z|0-9]+\z/, message: 'invalid format - expected format is : {[A-Z|a-z|0-9]}'}, length: {maximum: 50}
  validates :name, format: {with: /\A[A-Z|a-z|0-9|\s|\.|\-]+\z/, message: 'invalid format - expected format is : {[A-Z|a-z|0-9|\s|\.|\-]}'}, length: {maximum: 50}
end