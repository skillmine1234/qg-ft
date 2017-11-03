require 'will_paginate/array'

class FtPurposeCodesController < ApplicationController
  authorize_resource
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  include FtPurposeCodeHelper
  
  def new
    @ft_purpose_code = FtPurposeCode.new
  end

  def create
    @ft_purpose_code = FtPurposeCode.new(params[:ft_purpose_code])
    if !@ft_purpose_code.valid?
      render "new"
    else
      @ft_purpose_code.created_by = current_user.id
      @ft_purpose_code.save!
      flash[:alert] = 'FT Purpose Code successfully created and is pending for approval'
      redirect_to @ft_purpose_code
    end
  end 

  def edit
    ft_purpose_code = FtPurposeCode.unscoped.find_by_id(params[:id])
    if ft_purpose_code.approval_status == 'A' && ft_purpose_code.unapproved_record.nil?
      params = (ft_purpose_code.attributes).merge({:approved_id => ft_purpose_code.id,:approved_version => ft_purpose_code.lock_version})
      ft_purpose_code = FtPurposeCode.new(params)
    end
    @ft_purpose_code = ft_purpose_code 
  end

  def update
    @ft_purpose_code = FtPurposeCode.unscoped.find_by_id(params[:id])
    @ft_purpose_code.attributes = params[:ft_purpose_code]
    if !@ft_purpose_code.valid?
      render "edit"
    else
      @ft_purpose_code.updated_by = current_user.id
      @ft_purpose_code.save!
      flash[:alert] = 'FT Purpose Code successfully modified and is pending for approval'
      redirect_to @ft_purpose_code
    end
    rescue ActiveRecord::StaleObjectError
      @ft_purpose_code.reload
      flash[:alert] = 'Someone edited the ft_purpose_code the same time you did. Please re-apply your changes to the ft_purpose_code.'
      render "edit"
  end 

  def show
    @ft_purpose_code = FtPurposeCode.unscoped.find_by_id(params[:id])
  end

  def index
    if params[:advanced_search].present?
      ft_purpose_codes = find_ft_purpose_codes(params).order("id desc")
    else
      ft_purpose_codes = (params[:approval_status].present? and params[:approval_status] == 'U') ? FtPurposeCode.unscoped.where("approval_status =?",'U').order("id desc") : FtPurposeCode.order("id desc")
    end
    @ft_purpose_codes_count = ft_purpose_codes.count
    @ft_purpose_codes = ft_purpose_codes.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def audit_logs
    @ft_purpose_code = FtPurposeCode.unscoped.find(params[:id]) rescue nil
    @audit = @ft_purpose_code.audits[params[:version_id].to_i] rescue nil
  end
  
  def approve
    @ft_purpose_code = FtPurposeCode.unscoped.find(params[:id]) rescue nil
    FtPurposeCode.transaction do
      approval = @ft_purpose_code.approve
      if @ft_purpose_code.save and approval.empty?
        flash[:alert] = "FtPurposeCode record was approved successfully"
      else
        msg = approval.empty? ? @ft_purpose_code.errors.full_messages : @ft_purpose_code.errors.full_messages << approval
        flash[:alert] = msg
        raise ActiveRecord::Rollback
      end
    end
    redirect_to @ft_purpose_code
  end

  private

  def ft_purpose_code_params
    params.require(:ft_purpose_code).permit(:code, :description, :is_enabled, :allow_only_registered_bene, :created_by, :updated_by,
                                            :lock_version, :approval_status, :approved_version, :approved_id, {:allowed_transfer_types => []},
                                            :is_frozen, :settings_cnt, 
                                            :setting1_name, :setting1_type, :setting1_value, 
                                            :setting2_name, :setting2_type, :setting2_value, 
                                            :setting3_name, :setting3_type, :setting3_value, 
                                            :setting4_name, :setting4_type, :setting4_value,
                                            :setting5_name, :setting5_type, :setting5_value)
  end
  
end