require 'spec_helper'

describe FtApbsIncomingRecordSearcher do
  context 'searcher' do
    it 'should return ft_apbs_incoming_records' do
      a = Factory(:ft_apbs_incoming_record, :incoming_file_record => Factory(:incoming_file_record, :overrides => 'Y:76',:record_no => 23))
      FtApbsIncomingRecordSearcher.new({overrided_flag: "true",file_name: a.file_name, status: 'FAILED'}).paginate.should == [a]

      ft_apbs_incoming_record = Factory(:ft_apbs_incoming_record, :apbs_trans_code => '2222')
      FtApbsIncomingRecordSearcher.new({apbs_trans_code: '2222', file_name: ft_apbs_incoming_record.file_name, status: 'FAILED'}).paginate.should == [ft_apbs_incoming_record]
      FtApbsIncomingRecordSearcher.new({apbs_trans_code: '2223', file_name: ft_apbs_incoming_record.file_name, status: 'FAILED'}).paginate.should == []

      ft_apbs_incoming_record = Factory(:ft_apbs_incoming_record, :file_name => 'File01', :dest_bank_iin => 'YESB')
      FtApbsIncomingRecordSearcher.new({file_name: ft_apbs_incoming_record.file_name, dest_bank_iin: 'YESB', status: 'FAILED'}).paginate.should == [ft_apbs_incoming_record]
      FtApbsIncomingRecordSearcher.new({file_name: ft_apbs_incoming_record.file_name, dest_bank_iin: 'HDFC', status: 'FAILED'}).paginate.should == []

      ft_apbs_incoming_record = Factory(:ft_apbs_incoming_record, :file_name => 'File02', :bene_acct_name => 'Job')
      FtApbsIncomingRecordSearcher.new({file_name: ft_apbs_incoming_record.file_name, bene_acct_name: 'Job', status: 'FAILED'}).paginate.should == [ft_apbs_incoming_record]
      FtApbsIncomingRecordSearcher.new({file_name: ft_apbs_incoming_record.file_name, bene_acct_name: 'Foo', status: 'FAILED'}).paginate.should == []

      ft_apbs_incoming_record = Factory(:ft_apbs_incoming_record, :file_name => 'File01', :sponser_bank_iin => 'YESB')
      FtApbsIncomingRecordSearcher.new({file_name: ft_apbs_incoming_record.file_name, sponser_bank_iin: 'YESB', status: 'FAILED'}).paginate.should == [ft_apbs_incoming_record]
      FtApbsIncomingRecordSearcher.new({file_name: ft_apbs_incoming_record.file_name, sponser_bank_iin: 'HDFC', status: 'FAILED'}).paginate.should == []
    end
  end
end