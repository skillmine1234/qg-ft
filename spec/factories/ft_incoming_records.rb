# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ft_incoming_record do
    incoming_file_record_id {Factory(:incoming_file_record, :incoming_file => Factory(:incoming_file,:file_type => 'FUNDSTRANSFER',:service_name => 'FUNDSTRANSFER')).id}
    file_name {Factory(:incoming_file).file_name}
    req_no 0000
    rep_attempt_no 1
    txn_status_code "MyString"
    req_version "MyString"
    customer_code "MyString"
    debit_account_no "MyString"
    req_transfer_type "abcd"
    transfer_ccy "wer"
    transfer_amount 2000
  end
end