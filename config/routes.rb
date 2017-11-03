Rails.application.routes.draw do
  
  resources :funds_transfers, :inward_remittances, :whitelisted_identities, only: [:index, :show] do
    collection do
      put :index
    end
    member do
      get :notifications
    end
  end

  resources :ft_unapproved_records
  resources :funds_transfer_customers do
    member do
      put :resend_notification
    end
  end
  resources :ft_purpose_codes
  resources :ft_customer_accounts
  resources :ft_incoming_records
  resources :ft_apbs_incoming_records, except: :index do
    collection do
      get :index
      post :index
    end
  end
  resources :ft_saf_transfers, except: :index do
    collection do
      get :index
      put :index
    end
    member do
      put :delete
    end    
  end
  
  resources :ft_purge_saf_transfers, except: [:edit, :update] do
    member do
      put :approve
    end
  end
  get 'ft_incoming_file_summary' => 'ft_incoming_records#incoming_file_summary'
  get '/ft_incoming_records/:id/audit_logs' => 'ft_incoming_records#audit_logs'
  get '/ft_purpose_code/:id/audit_logs' => 'ft_purpose_codes#audit_logs'
  get '/ft_customer_account/:id/audit_logs' => 'ft_customer_accounts#audit_logs'
  put '/funds_transfer_customer/:id/approve' => "funds_transfer_customers#approve"
  put '/ft_purpose_code/:id/approve' => "ft_purpose_codes#approve"
  put '/ft_customer_account/:id/approve' => "ft_customer_accounts#approve"
  get 'ft_apbs_incoming_file_summary' => 'ft_apbs_incoming_records#incoming_file_summary'
  get '/ft_apbs_incoming_records/:id/audit_logs' => 'ft_apbs_incoming_records#audit_logs'
  get '/funds_transfer_customer/:id/audit_logs' => 'funds_transfer_customers#audit_logs'
  
end
