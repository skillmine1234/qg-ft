# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :funds_transfer_customer do
    sequence(:app_id) {|n| "abcd#{n}"} 
    name "MyString"
    low_balance_alert_at 123
    identity_user_id { Factory(:iam_cust_user, approval_status: 'A').username }
    sequence(:customer_id) {|n| "9" + "%05i" % "#{n}" }
    approval_status "U"
    allow_neft "N"
    allow_imps "N"
    enabled "N"
    allow_all_accounts "Y"
  end
end
