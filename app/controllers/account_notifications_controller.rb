class AccountNotificationsController < ApplicationController
  before_filter :require_account_admin
  
  def create
    @notification = AccountNotification.new(params[:account_notification])
    @notification.account = @account
    @notification.user = @current_user
    respond_to do |format|
      if @notification.save
        flash[:notice] = t(:alert_created_notice, "Alert successfully created")
        format.html { redirect_to account_settings_path(@account, :anchor => 'tab-alerts') }
        format.json { render :json => @notification.to_json }
      else
        flash[:error] = t(:alert_creation_failed_notice, "Alert creation failed")
        format.html { redirect_to account_settings_path(@account, :anchor => 'tab-alerts') }
        format.json { render :json => @notification.errors.to_json, :status => :bad_request }
      end
    end
  end
  
  def destroy
    @notification = @account.account_notifications.find(params[:id])
    @notification.destroy
    respond_to do |format|
      flash[:message] = t(:alert_deleted_notice, "Alert successfully deleted")
      format.html { redirect_to account_settings_path(@account) }
      format.json { render :json => @notification.to_json }
    end
  end
  
  protected
  def require_account_admin
    get_context
    if !@account || @account.parent_account_id
      flash[:notice] = t(:permission_denied_notice, "You cannot create alerts for that account")
      redirect_to account_settings_path(params[:account_id])
      return false
    end
    return false unless authorized_action(@account, @current_user, :manage_alerts)
  end
end
