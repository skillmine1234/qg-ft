require 'will_paginate/array'

class FtApbsIncomingRecordsController < ApplicationController
  authorize_resource
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json, :html
  include SuIncomingRecordsHelper

  def index
    @incoming_file = IncomingFile.find_by_file_name(params[:file_name]) rescue nil
    if request.get?
      # only 'safe/non-personal' parameters are allowed as search parameters in a query string
      @searcher = FtApbsIncomingRecordSearcher.new(params.permit(:status, :file_name, :overrided_flag, :page))
    else
      # rest parameters are in post
      @searcher = FtApbsIncomingRecordSearcher.new(search_params)
    end
    @records = @searcher.paginate
  end

  def show
    @ft_apbs_record = FtApbsIncomingRecord.find_by_id(params[:id])
  end

  def audit_logs
    @record = IncomingFileRecord.find(params[:id]) rescue nil
    @audit = @record.audits[params[:version_id].to_i] rescue nil
  end

  def incoming_file_summary
    @summary = FtApbsIncomingFile.find_by_file_name(params[:file_name])
  end

  def search_params
    params.permit(:page, :apbs_trans_code, :dest_bank_iin, :bene_acct_name, :sponser_bank_iin, :status, :file_name, :overrided_flag)
  end
end