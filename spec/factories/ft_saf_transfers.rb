FactoryGirl.define do
  factory :ft_saf_transfer do
    sequence(:customer_id) {|n| "#{n}" }
    app_uuid 'MyString'
    req_no 'MyString'
    op_name 'MyString'
    app_id 'MyString'
    status_code 'MyString'
    req_timestamp Time.now
    rep_timestamp Time.now
  end
end
