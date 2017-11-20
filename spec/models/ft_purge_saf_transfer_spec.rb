require 'spec_helper'

describe FtPurgeSafTransfer do
  context 'association' do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
    it { should have_one(:ft_unapproved_record) }
    it { should belong_to(:unapproved_record) }
    it { should belong_to(:approved_record) }
  end

  context 'validation' do
    [:reference_no, :from_req_timestamp, :to_req_timestamp].each do |att|
      it { should validate_presence_of(att) }
    end
    it { should validate_length_of(:customer_id).is_at_most(15) }

    it do 
      ft_purge_saf_transfer = Factory(:ft_purge_saf_transfer, :approval_status => 'A')
      should validate_uniqueness_of(:reference_no).scoped_to(:approval_status)  
    end
  end
  
  context "default_scope" do 
    it "should only return 'A' records by default" do 
      ft_purge_saf_transfer1 = Factory(:ft_purge_saf_transfer, :approval_status => 'A') 
      ft_purge_saf_transfer2 = Factory(:ft_purge_saf_transfer)
      FtPurgeSafTransfer.all.should == [ft_purge_saf_transfer1]
      ft_purge_saf_transfer2.approval_status = 'A'
      ft_purge_saf_transfer2.save
      FtPurgeSafTransfer.all.should == [ft_purge_saf_transfer1, ft_purge_saf_transfer2]
    end
  end    

  context "ft_unapproved_records" do 
    it "oncreate: should create ft_unapproved_record if the approval_status is 'U'" do
      ft_purge_saf_transfer = Factory(:ft_purge_saf_transfer)
      ft_purge_saf_transfer.reload
      ft_purge_saf_transfer.ft_unapproved_record.should_not be_nil
    end

    it "oncreate: should not create ft_unapproved_record if the approval_status is 'A'" do
      ft_purge_saf_transfer = Factory(:ft_purge_saf_transfer, :approval_status => 'A')
      ft_purge_saf_transfer.ft_unapproved_record.should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      ft_purge_saf_transfer = Factory(:ft_purge_saf_transfer, :approval_status => 'U')
      ft_purge_saf_transfer.approve.should == ""
      ft_purge_saf_transfer.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      ft_purge_saf_transfer = Factory(:ft_purge_saf_transfer, :approval_status => 'A')
      ft_purge_saf_transfer2 = Factory(:ft_purge_saf_transfer, :approval_status => 'U', :approved_id => ft_purge_saf_transfer.id, :approved_version => 6)
      ft_purge_saf_transfer2.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      ft_purge_saf_transfer1 = Factory(:ft_purge_saf_transfer, :approval_status => 'A')
      ft_purge_saf_transfer2 = Factory(:ft_purge_saf_transfer, :approval_status => 'U')
      ft_purge_saf_transfer1.enable_approve_button?.should == false
      ft_purge_saf_transfer2.enable_approve_button?.should == true
    end
  end
  
end