class NachMembersController < ApplicationController
  #authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  
  def new
    @nach_member = NachMember.new
  end

  def create
    @nach_member = NachMember.new(params[:nach_member])
    if !@nach_member.valid?
      render "new"
    else
      @nach_member.created_by = current_user.id
      @nach_member.save!
      flash[:alert] = "Nach Member successfully #{@nach_member.approved_id.nil? ? 'created' : 'updated'} and is pending for approval"
      redirect_to @nach_member
    end
  end 

  def edit
    nach_member = NachMember.unscoped.find_by_id(params[:id])
    if nach_member.approval_status == 'A' && nach_member.unapproved_record.nil?
      params = (nach_member.attributes).merge({:approved_id => nach_member.id,:approved_version => nach_member.lock_version})
      nach_member = NachMember.new(params)
    end
    @nach_member = nach_member   
  end

  def update
    @nach_member = NachMember.unscoped.find_by_id(params[:id])
    @nach_member.attributes = params[:nach_member]
    if !@nach_member.valid?
      render "edit"
    else
      @nach_member.updated_by = current_user.id
      @nach_member.save!
      flash[:alert] = 'Nach Member successfully modified and is pending for approval'
      redirect_to @nach_member
    end
    rescue ActiveRecord::StaleObjectError
      @nach_member.reload
      flash[:alert] = 'Someone edited the record the same time you did. Please re-apply your changes to the record.'
      render "edit"
  end 

  def show
    @nach_member = NachMember.unscoped.find_by_id(params[:id])
  end

  def index
    if request.get?
      @searcher = NachMemberSearcher.new(params.permit(:page, :approval_status))
    else
      @searcher = NachMemberSearcher.new(search_params)
    end
    @records = @searcher.paginate
  end

  def audit_logs
    @record = NachMember.unscoped.find(params[:id]) rescue nil
    @audit = @record.audits[params[:version_id].to_i] rescue nil
  end
  
  def approve
    @nach_member = NachMember.unscoped.find(params[:id]) rescue nil
    NachMember.transaction do
      approval = @nach_member.approve
      if @nach_member.save and approval.empty?
        flash[:alert] = "Nach Member record was approved successfully"
      else
        msg = approval.empty? ? @nach_member.errors.full_messages : @nach_member.errors.full_messages << approval
        flash[:alert] = msg
        raise ActiveRecord::Rollback
      end
    end
    redirect_to @nach_member
  end

  private    
    def search_params
      params.require(:nach_member_searcher).permit( :page, :approval_status, :iin, :name)
    end 


  def nach_member_params
    params.require(:nach_member).permit(:iin, :name, :is_enabled, :created_at, :updated_at, :created_by, :updated_by, :lock_version, 
                                        :approval_status, :last_action, :approved_version, :approved_id)
  end
end
