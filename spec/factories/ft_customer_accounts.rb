# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ft_customer_account do
    sequence(:account_no) {|n| "9" + "%05i" % "#{n}"} 
    customer_id {Factory(:funds_transfer_customer, :enabled => 'Y', :approval_status => 'A').customer_id}
    is_enabled 'N'
    approval_status 'U'
  end
end
