FactoryGirl.define do
  factory :funds_transfer do
    req_no 0000
    attempt_no 1
    status_code "MyString"
    req_version "MyString"
    req_timestamp "2015-12-12 12:12:12"
    customer_id "MyString"
    debit_account_no "MyString"
    req_transfer_type "abcd"
    transfer_ccy "wer"
    transfer_amount 2000
  end
end