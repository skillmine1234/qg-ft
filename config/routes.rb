Rails.application.routes.draw do
  
  resources :funds_transfers, :inward_remittances, :whitelisted_identities, only: [:index, :show] do
    collection do
      post :index
    end
    member do
      get :steps
    end
  end

  resources :ft_unapproved_records
  resources :funds_transfer_customers do
    member do
      post :resend_notification
    end
    collection do
      post :index
      get :validate_customer_id_ft_customer
      get :validate_app_id_ft_customer
      post :create_clone_accounts
      get :check_duplicate_account_no
      get :display_associated_customer_id
      get :validate_app_id_child_ft_customer
      post :create_child_ft_customers
      get :check_duplicate_customer_id
      get :validate_app_id_customer_id_ft_customer
      match :deactivate_user, via: [:get, :post]
      post :deactivation_customer_final_list
      patch :index
    end
  end

  resources :ft_customer_disable_lists
  post '/ft_customer_disable_lists/:id/approve' => "ft_customer_disable_lists#approve"

  resources :ft_customer_accounts, :ft_purpose_codes, :ft_incoming_records do
    collection do
      patch :index
    end
  end

  resources :ft_apbs_incoming_records, except: :index do
    collection do
      get :index
      patch :index
    end
  end
  resources :ft_saf_transfers, except: :index do
    collection do
      get :index
      patch :index
    end
    member do
      post :delete
    end    
  end
  
  resources :ft_purge_saf_transfers, except: [:edit, :update] do
    member do
      post :approve
      patch :index
    end
  end
  
  resources :nach_members do
    collection do
      get :index
      patch :index
    end
    member do
      post :approve
      get :audit_logs
    end
  end
  
  resources :ft_invoice_details do
    collection do
      patch :index
    end
    member do
      get :steps
    end
  end

  # operation_routes_for 'ft_invoice_details'

  get 'ft_incoming_file_summary' => 'ft_incoming_records#incoming_file_summary'
  get '/ft_incoming_records/:id/audit_logs' => 'ft_incoming_records#audit_logs'
  get '/ft_purpose_code/:id/audit_logs' => 'ft_purpose_codes#audit_logs'
  get '/ft_customer_account/:id/audit_logs' => 'ft_customer_accounts#audit_logs'
  post '/funds_transfer_customer/:id/approve' => "funds_transfer_customers#approve"
  post '/ft_purpose_code/:id/approve' => "ft_purpose_codes#approve"
  post '/ft_customer_account/:id/approve' => "ft_customer_accounts#approve"
  get 'ft_apbs_incoming_file_summary' => 'ft_apbs_incoming_records#incoming_file_summary'
  get '/ft_apbs_incoming_records/:id/audit_logs' => 'ft_apbs_incoming_records#audit_logs'
  get '/funds_transfer_customer/:id/audit_logs' => 'funds_transfer_customers#audit_logs'
  
end
