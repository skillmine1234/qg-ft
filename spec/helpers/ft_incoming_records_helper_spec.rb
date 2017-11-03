require 'spec_helper'

describe FtIncomingRecordsHelper do
  context "find_ft_incoming_records" do
    it "should return records for the params that is passed" do 
      a = Factory(:ft_incoming_record, :incoming_file_record => Factory(:incoming_file_record, :overrides => 'Y:76',:record_no => 23))
      find_ft_incoming_records({:overrided_flag => "true"},FtIncomingRecord.joins(:incoming_file_record)).should == [a]
      
      ft_incoming_record = Factory(:ft_incoming_record, :req_no => '2222')
      find_ft_incoming_records({:req_no => '2222'},FtIncomingRecord.joins(:incoming_file_record)).should == [ft_incoming_record]
      find_ft_incoming_records({:req_no => '2223'},FtIncomingRecord.joins(:incoming_file_record)).should == []

      ft_incoming_record = Factory(:ft_incoming_record, :bank_ref_no=> '2222')
      find_ft_incoming_records({:bank_ref_no => '2222'},FtIncomingRecord.joins(:incoming_file_record)).should == [ft_incoming_record]
      find_ft_incoming_records({:bank_ref_no => '2223'},FtIncomingRecord.joins(:incoming_file_record)).should == []

      ft_incoming_record = Factory(:ft_incoming_record, :debit_account_no => '1234567')
      find_ft_incoming_records({:debit_account_no  => '1234567'},FtIncomingRecord.joins(:incoming_file_record)).should == [ft_incoming_record]
      find_ft_incoming_records({:debit_account_no  => '12345'},FtIncomingRecord.joins(:incoming_file_record)).should == []

      ft_incoming_record = Factory(:ft_incoming_record, :bene_account_no => '1234567')
      find_ft_incoming_records({:bene_account_no  => '1234567'},FtIncomingRecord.joins(:incoming_file_record)).should == [ft_incoming_record]
      find_ft_incoming_records({:bene_account_no  => '12345'},FtIncomingRecord.joins(:incoming_file_record)).should == []

      ft_incoming_record = Factory(:ft_incoming_record, :req_transfer_type => 'NEFT')
      find_ft_incoming_records({:req_transfer_type  => 'NEFT'},FtIncomingRecord.joins(:incoming_file_record)).should == [ft_incoming_record]
      find_ft_incoming_records({:req_transfer_type  => 'IMPS'},FtIncomingRecord.joins(:incoming_file_record)).should == []

      ft_incoming_record = Factory(:ft_incoming_record, :transfer_type => 'NEFT')
      find_ft_incoming_records({:transfer_type  => 'NEFT'},FtIncomingRecord.joins(:incoming_file_record)).should == [ft_incoming_record]
      find_ft_incoming_records({:transfer_type  => 'IMPS'},FtIncomingRecord.joins(:incoming_file_record)).should == []

      FtIncomingRecord.delete_all
      ft_incoming_record = Factory(:ft_incoming_record, :transfer_amount => 100)
      find_ft_incoming_records({:from_amount => 50},FtIncomingRecord.joins(:incoming_file_record)).should == [ft_incoming_record]
      find_ft_incoming_records({:to_amount => 150},FtIncomingRecord.joins(:incoming_file_record)).should == [ft_incoming_record]
    end
  end
end