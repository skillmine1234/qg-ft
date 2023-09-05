require 'spec_helper'

describe FtApbsIncomingFile do
  context 'association' do
    it { should have_one(:incoming_file) }
  end
end