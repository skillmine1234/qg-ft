require 'spec_helper'

describe NachMemberSearcher do

  context 'searcher' do
    it 'should return nach_member records with matching data' do      
      nach_member = Factory(:nach_member, iin: 'C123', approval_status: 'A')
      NachMemberSearcher.new({iin: 'C123'}).paginate.should == [nach_member]
      NachMemberSearcher.new({iin: 'D234'}).paginate.should == []

      nach_member = Factory(:nach_member, name: 'Cooperative Bank', approval_status: 'A')
      NachMemberSearcher.new({name: 'Cooperative Bank'}).paginate.should == [nach_member]
      NachMemberSearcher.new({name: 'ABC Bank'}).paginate.should == []
    end
  end
end