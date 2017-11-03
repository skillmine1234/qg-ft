FactoryGirl.define do
  factory :ft_unapproved_record do
    ft_approvable_id 1
    ft_approvable_type "MyString"
  end
end