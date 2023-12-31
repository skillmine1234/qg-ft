require 'will_paginate/array'

class FtUnapprovedRecordsController < ApplicationController
  #authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  include FtUnapprovedRecordsHelper

  def index
    records = filter_records(FtUnapprovedRecord)
    @records = records.paginate(:per_page => 10, :page => params[:page]) rescue []
  end
end
