require 'spec_helper'

describe FtPurposeCode do
  context 'association' do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
    it { should have_one(:ft_unapproved_record) }
    it { should belong_to(:unapproved_record) }
    it { should belong_to(:approved_record) }
  end

  context 'validation' do
    [:code, :description, :is_enabled, :allowed_transfer_types].each do |att|
      it { should validate_presence_of(att) }
    end

    it do
      ft_purpose_code = Factory(:ft_purpose_code) 
      should validate_uniqueness_of(:code).scoped_to(:approval_status)
    end
    
    [:code].each do |att|
      it { should validate_length_of(att).is_at_least(2) }
      it { should validate_length_of(att).is_at_most(6) }
    end
    
    it "should validate_unapproved_record" do 
      ft_purpose_code1 = Factory(:ft_purpose_code,:approval_status => 'A')
      ft_purpose_code2 = Factory(:ft_purpose_code, :approved_id => ft_purpose_code1.id)
      ft_purpose_code1.should_not be_valid
      ft_purpose_code1.errors_on(:base).should == ["Unapproved Record Already Exists for this record"]
    end

    context "code format" do
      it "should allow valid format" do 
        [:code].each do |att|
          should allow_value('ab1V').for(att)
          should allow_value('acde').for(att)
          should allow_value('1343').for(att)
          should allow_value('aBCD').for(att)
        end
      end

      it "should not allow invalid format" do 
        [:code].each do |att|
          should_not allow_value('a 1V').for(att)
          should_not allow_value('@acd').for(att)
          should_not allow_value('134\n').for(att)
        end
      end
    end

    context "description format" do
      it "should allow valid format" do
        should allow_value('Abc def. Geh-ijk.').for(:description)
      end

      it "should not allow invalid format" do
        should_not allow_value('@AbcCo').for(:description)
        should_not allow_value('/ab0QWER').for(:description)

        ft_purpose_code = Factory.build(:ft_purpose_code, :description => 'ABC@DEF')
        ft_purpose_code.save == false
        ft_purpose_code.errors_on(:description).should == ["Invalid format, expected format is : {[a-z|A-Z|0-9|\\s|\\.|\\-]}"]
      end
    end
  end
  
  context "default_scope" do 
    it "should only return 'A' records by default" do 
      ft_purpose_code1 = Factory(:ft_purpose_code, :approval_status => 'A') 
      ft_purpose_code2 = Factory(:ft_purpose_code, :code => "0002")
      FtPurposeCode.all.should == [ft_purpose_code1]
      ft_purpose_code2.approval_status = 'A'
      ft_purpose_code2.save
      FtPurposeCode.all.should == [ft_purpose_code1, ft_purpose_code2]
    end
  end    

  context "ft_unapproved_records" do 
    it "oncreate: should create ft_unapproved_record if the approval_status is 'U'" do
      ft_purpose_code = Factory(:ft_purpose_code)
      ft_purpose_code.reload
      ft_purpose_code.ft_unapproved_record.should_not be_nil
    end

    it "oncreate: should not create ft_unapproved_record if the approval_status is 'A'" do
      ft_purpose_code = Factory(:ft_purpose_code, :approval_status => 'A')
      ft_purpose_code.ft_unapproved_record.should be_nil
    end

    it "onupdate: should not remove ft_unapproved_record if approval_status did not change from U to A" do
      ft_purpose_code = Factory(:ft_purpose_code)
      ft_purpose_code.reload
      ft_purpose_code.ft_unapproved_record.should_not be_nil
      record = ft_purpose_code.ft_unapproved_record
      # we are editing the U record, before it is approved
      ft_purpose_code.description = 'Fooo'
      ft_purpose_code.save
      ft_purpose_code.reload
      ft_purpose_code.ft_unapproved_record.should == record
    end
    
    it "onupdate: should remove ft_unapproved_record if the approval_status changed from 'U' to 'A' (approval)" do
      ft_purpose_code = Factory(:ft_purpose_code)
      ft_purpose_code.reload
      ft_purpose_code.ft_unapproved_record.should_not be_nil
      # the approval process changes the approval_status from U to A for a newly edited record
      ft_purpose_code.approval_status = 'A'
      ft_purpose_code.save
      ft_purpose_code.reload
      ft_purpose_code.ft_unapproved_record.should be_nil
    end
    
    it "ondestroy: should remove ft_unapproved_record if the record with approval_status 'U' was destroyed (approval) " do
      ft_purpose_code = Factory(:ft_purpose_code)
      ft_purpose_code.reload
      ft_purpose_code.ft_unapproved_record.should_not be_nil
      record = ft_purpose_code.ft_unapproved_record
      # the approval process destroys the U record, for an edited record 
      ft_purpose_code.destroy
      FtUnapprovedRecord.find_by_id(record.id).should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      ft_purpose_code = Factory(:ft_purpose_code, :approval_status => 'U')
      ft_purpose_code.approve.should == ""
      ft_purpose_code.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      ft_purpose_code = Factory(:ft_purpose_code, :approval_status => 'A')
      ft_purpose_code2 = Factory(:ft_purpose_code, :approval_status => 'U', :approved_id => ft_purpose_code.id, :approved_version => 6)
      ft_purpose_code2.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      ft_purpose_code1 = Factory(:ft_purpose_code, :approval_status => 'A')
      ft_purpose_code2 = Factory(:ft_purpose_code, :approval_status => 'U')
      ft_purpose_code1.enable_approve_button?.should == false
      ft_purpose_code2.enable_approve_button?.should == true
    end
  end
  
  context "value_for_reg_bene_for_apbs" do
    it "should validate whether the value of allow_only_registered_bene is N if allowed_transfer_type is APBS" do
      ft_purpose_code = Factory.build(:ft_purpose_code, :approval_status => 'A', allowed_transfer_types: ['APBS'], allow_only_registered_bene: 'Y')
      ft_purpose_code.errors_on(:allow_only_registered_bene).should == ["Allow Only Registered Bene cannot be enabled when APBS is allowed"]
    end
  end
  
  context "check_allowed_transfer_types" do
    it "should validate allowed_transfer_types" do
      ft_purpose_code = Factory.build(:ft_purpose_code, :approval_status => 'A', allowed_transfer_types: ['APBS'])
      ft_purpose_code.errors_on(:allowed_transfer_types).should == []
      
      ft_purpose_code = Factory.build(:ft_purpose_code, :approval_status => 'A', allowed_transfer_types: ['APBS','IMPS','NEFT'])
      ft_purpose_code.errors_on(:allowed_transfer_types).should == ['Either APBS or one or more of [IMPS, NEFT, RTGS] can be selected']
    end
  end
  
  context "set_settings_cnt" do
    it "should set counts of settings" do
      ft_purpose_code = Factory(:ft_purpose_code, setting1_name: 'set1', setting1_type: 'number', setting1_value: 1)
      ft_purpose_code.settings_cnt.should == 1
    end
  end

  context "set_transfer_type" do
    it "should set transfer type" do
      ft_purpose_code = Factory(:ft_purpose_code, :approval_status => 'A', :allowed_transfer_types => ['APBS'])
      ft_purpose_code1 = Factory.build(:ft_purpose_code, :approval_status => 'U', :approved_id => ft_purpose_code.id, :allowed_transfer_types => nil)
      ft_purpose_code1.should be_valid
      ft_purpose_code1.allowed_transfer_types.should == ['APBS']
    end
  end
  
end