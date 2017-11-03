FactoryGirl.define do
  factory :ft_apbs_incoming_file do
    file_name {Factory(:incoming_file).file_name}
  end
end
