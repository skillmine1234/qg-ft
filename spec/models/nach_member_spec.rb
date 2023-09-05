require 'spec_helper'

describe NachMember do
  context 'association' do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
    it { should have_one(:ft_unapproved_record) }
    it { should belong_to(:unapproved_record) }
    it { should belong_to(:approved_record) }
  end

  context 'validation' do
    [:iin, :name, :is_enabled].each do |att|
      it { should validate_presence_of(att) }
    end

    it do
      nach_member1 = Factory(:nach_member, iin: '12312', name: 'ABCD 123', approval_status: 'A')
      should validate_uniqueness_of(:iin).scoped_to(:approval_status)
    end

    [:iin, :name].each do |att|
      it { should validate_length_of(att).is_at_most(50) }
    end
    
    it "should validate_unapproved_record" do 
      nach_member1 = Factory(:nach_member,:approval_status => 'A')
      nach_member2 = Factory(:nach_member, :approved_id => nach_member1.id)
      nach_member1.should_not be_valid
      nach_member1.errors_on(:base).should == ["Unapproved Record Already Exists for this record"]
    end

    context "fields format" do
      it "should allow valid format" do 
        [:name].each do |att|
          should allow_value('ab1V').for(att)
          should allow_value('acde').for(att)
          should allow_value('1343').for(att)
          should allow_value('abc-pvt. ltd').for(att)
        end
        [:iin].each do |att|
          should allow_value('ab1V').for(att)
          should allow_value('acde').for(att)
          should allow_value('1343').for(att)
        end
      end

      it "should not allow invalid format" do 
        [:name].each do |att|
          should_not allow_value('@acd').for(att)
          should_not allow_value('134\n').for(att)
        end
        [:iin].each do |att|
          should_not allow_value('@acd').for(att)
          should_not allow_value('134\n.-').for(att)
        end
      end
    end
  end
  
  context "default_scope" do 
    it "should only return 'A' records by default" do 
      nach_member1 = Factory(:nach_member, :approval_status => 'A') 
      nach_member2 = Factory(:nach_member, iin: "0002")
      NachMember.all.should == [nach_member1]
      nach_member2.approval_status = 'A'
      nach_member2.save
      NachMember.all.should == [nach_member1, nach_member2]
    end
  end    

  context "ft_unapproved_records" do 
    it "oncreate: should create ft_unapproved_record if the approval_status is 'U'" do
      nach_member = Factory(:nach_member)
      nach_member.reload
      nach_member.ft_unapproved_record.should_not be_nil
    end

    it "oncreate: should not create ft_unapproved_record if the approval_status is 'A'" do
      nach_member = Factory(:nach_member, :approval_status => 'A')
      nach_member.ft_unapproved_record.should be_nil
    end

    it "onupdate: should not remove ft_unapproved_record if approval_status did not change from U to A" do
      nach_member = Factory(:nach_member)
      nach_member.reload
      nach_member.ft_unapproved_record.should_not be_nil
      record = nach_member.ft_unapproved_record
      # we are editing the U record, before it is approved
      nach_member.name = 'Fooo'
      nach_member.save
      nach_member.reload
      nach_member.ft_unapproved_record.should == record
    end
    
    it "onupdate: should remove ft_unapproved_record if the approval_status changed from 'U' to 'A' (approval)" do
      nach_member = Factory(:nach_member)
      nach_member.reload
      nach_member.ft_unapproved_record.should_not be_nil
      # the approval process changes the approval_status from U to A for a newly edited record
      nach_member.approval_status = 'A'
      nach_member.save
      nach_member.reload
      nach_member.ft_unapproved_record.should be_nil
    end
    
    it "ondestroy: should remove ft_unapproved_record if the record with approval_status 'U' was destroyed (approval) " do
      nach_member = Factory(:nach_member)
      nach_member.reload
      nach_member.ft_unapproved_record.should_not be_nil
      record = nach_member.ft_unapproved_record
      # the approval process destroys the U record, for an edited record 
      nach_member.destroy
      FtUnapprovedRecord.find_by_id(record.id).should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      nach_member = Factory(:nach_member, :approval_status => 'U')
      nach_member.approve.should == ""
      nach_member.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      nach_member = Factory(:nach_member, :approval_status => 'A')
      nach_member2 = Factory(:nach_member, :approval_status => 'U', :approved_id => nach_member.id, :approved_version => 6)
      nach_member2.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      nach_member1 = Factory(:nach_member, :approval_status => 'A')
      nach_member2 = Factory(:nach_member, :approval_status => 'U')
      nach_member1.enable_approve_button?.should == false
      nach_member2.enable_approve_button?.should == true
    end
  end

  
end