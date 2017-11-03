FactoryGirl.define do
  factory :ft_apbs_incoming_record do
    incoming_file_record_id {Factory(:incoming_file_record, :incoming_file => Factory(:incoming_file,:file_type => 'APBS',:service_name => 'FUNDSTRANSFER')).id}
    sequence(:file_name) {|n| "file#{n}"} 
    apbs_trans_code 'MyString'
    dest_bank_iin 'MyString'
    dest_acctype 'MyString'
    ledger_folio_num 'MyString'
    bene_aadhar_num 'MyString'
    bene_acct_name 'MyString'
    sponser_bank_iin 'MyString'
    user_num 'MyString'
    user_name 'MyString'
    user_credit_ref 'MyString'
    amount 1000
    item_seq_num 'MyString'
    checksum 'MyString'
    success_flag 'MyString'
    filler 'MyString'
    reason_code 'MyString'
    dest_bank_acctnum 'MyString'
  end
end