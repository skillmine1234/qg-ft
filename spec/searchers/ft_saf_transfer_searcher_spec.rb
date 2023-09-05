require 'spec_helper'

describe FtSafTransferSearcher do

  context 'searcher' do
    it 'should return ft_saf_transfer records with matching data' do      
      ft_saf_transfer = Factory(:ft_saf_transfer, app_uuid: 'C123')
      FtSafTransferSearcher.new({app_uuid: 'C123'}).paginate.should == [ft_saf_transfer]
      FtSafTransferSearcher.new({app_uuid: 'D234'}).paginate.should == []
      
      ft_saf_transfer = Factory(:ft_saf_transfer, customer_id: '11231')
      FtSafTransferSearcher.new({customer_id: '11231'}).paginate.should == [ft_saf_transfer]
      FtSafTransferSearcher.new({customer_id: 'D234'}).paginate.should == []
      
      ft_saf_transfer = Factory(:ft_saf_transfer, op_name: 'transfer')
      FtSafTransferSearcher.new({op_name: 'transfer'}).paginate.should == [ft_saf_transfer]
      FtSafTransferSearcher.new({op_name: 'getBalance'}).paginate.should == []
      
      ft_saf_transfer = Factory(:ft_saf_transfer, status_code: 'FAILED')
      FtSafTransferSearcher.new({status: 'FAILED'}).paginate.should == [ft_saf_transfer]
      FtSafTransferSearcher.new({status: 'NEW'}).paginate.should == []
      
      ft_saf_transfer = Factory(:ft_saf_transfer, req_no: '2211')
      FtSafTransferSearcher.new({req_no: '2211'}).paginate.should == [ft_saf_transfer]
      FtSafTransferSearcher.new({req_no: 'D234'}).paginate.should == []
      
      ft_saf_transfer = Factory(:ft_saf_transfer, req_transfer_type: 'REQ123123')
      FtSafTransferSearcher.new({req_transfer_type: 'REQ123123'}).paginate.should == [ft_saf_transfer]
      FtSafTransferSearcher.new({req_transfer_type: 'D234'}).paginate.should == []
      
      ft_saf_transfers = [Factory(:ft_saf_transfer, :req_timestamp => '2015-04-25')]
      ft_saf_transfers << Factory(:ft_saf_transfer, :req_timestamp => '2015-04-26')
      ft_saf_transfers << Factory(:ft_saf_transfer, :req_timestamp => '2015-04-27')
      FtSafTransferSearcher.new({:from_request_timestamp => '2015-04-25', :to_request_timestamp => '2015-04-27'}).paginate.should == ft_saf_transfers.reverse
      FtSafTransferSearcher.new({:from_request_timestamp => '2015-04-28', :to_request_timestamp => '2015-04-30'}).paginate.should == []
      
      ft_saf_transfers = [Factory(:ft_saf_transfer, :rep_timestamp => '2015-04-25')]
      ft_saf_transfers << Factory(:ft_saf_transfer, :rep_timestamp => '2015-04-26')
      ft_saf_transfers << Factory(:ft_saf_transfer, :rep_timestamp => '2015-04-27')
      FtSafTransferSearcher.new({:from_reply_timestamp => '2015-04-25', :to_reply_timestamp => '2015-04-27'}).paginate.should == ft_saf_transfers.reverse
      FtSafTransferSearcher.new({:from_reply_timestamp => '2015-04-28', :to_reply_timestamp => '2015-04-30'}).paginate.should == []
    end
  end
end