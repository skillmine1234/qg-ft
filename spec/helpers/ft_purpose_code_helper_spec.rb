require 'spec_helper'

describe FtPurposeCodeHelper do
  context 'find_ft_purpose_code'do
    it 'should return ft_purpose_codes' do
      ft_purpose_code = Factory(:ft_purpose_code, :is_enabled => 'Y', :approval_status => 'A')
      find_ft_purpose_codes({:enabled => 'Y'}).should == [ft_purpose_code]
      find_ft_purpose_codes({:enabled => 'N'}).should == []
      ft_purpose_code = Factory(:ft_purpose_code, :code => '1232', :approval_status => 'A')
      find_ft_purpose_codes({:code => '1232'}).should == [ft_purpose_code]
      find_ft_purpose_codes({:code => '3212'}).should == []  
    end
  end  
end