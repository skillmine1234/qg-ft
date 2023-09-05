class FtCustomerDisableListsController < ApplicationController
  def index
  	@ft_disable_list = FtCustomerDisableList.unscoped.where("approval_status = ? and app_id IS NOT NULL and customer_id IS NOT NULL", "U").all
  end

  def show
  	@ft_disable_list = FtCustomerDisableList.unscoped.find_by_id(params[:id])
  end

   def approve
    @ft_disable_list = FtCustomerDisableList.unscoped.find(params[:id]) rescue nil
    FtCustomerDisableList.transaction do
      approval = @ft_disable_list.approve
      if @ft_disable_list.save and approval.empty?
      	app_ids = JSON.parse(@ft_disable_list.app_id)
      	customer_ids = JSON.parse(@ft_disable_list.customer_id)
      	FundsTransferCustomer.where("app_id IN (?) OR customer_id IN (?)",app_ids,customer_ids)
      	.update_all(enabled: "N")
        flash[:alert] = "Request was approved successfully"
      else
        msg = approval.empty? ? @ft_disable_list.errors.full_messages : @ft_disable_list.errors.full_messages << approval
        flash[:alert] = msg
        raise ActiveRecord::Rollback
      end
    end
    redirect_to @ft_disable_list
  end

end