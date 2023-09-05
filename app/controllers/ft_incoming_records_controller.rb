require 'will_paginate/array'

class FtIncomingRecordsController < ApplicationController
  #authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json, :html
  include SuIncomingRecordsHelper
  include FtIncomingRecordsHelper

  def index
    @incoming_file = IncomingFile.find_by_file_name(params[:file_name]) rescue nil
    records = FtIncomingRecord.joins(:incoming_file_record).where("ft_incoming_records.file_name=? and status=?",params[:file_name],params[:status]).order("ft_incoming_records.id desc")
    records = find_ft_incoming_records(params,records)
    @records_count = records.count(:status)
    @records = records.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def show
    @ft_record = FtIncomingRecord.find_by_id(params[:id])
  end

  def audit_logs
    @record = IncomingFileRecord.find(params[:id]) rescue nil
    @audit = @record.audits[params[:version_id].to_i] rescue nil
  end

  def incoming_file_summary
    @summary = FtIncomingFile.find_by_file_name(params[:file_name])
  end
end